# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# security: SSH + commit-signing keys, GPG agent, Cyberduck.

category security log "🔐 Setting up security..." "Set up security?" \
  setup-ssh setup-gpg setup-cyberduck

# The key git is actually configured to sign with, rather than whichever
# filename this script happens to prefer. Prints the private key path with ~
# expanded; fails if the setting is absent, holds a literal public key
# ("ssh-ed25519 AAAA..." instead of a path), or names a file that's gone.
signing-key-path() {
  local key
  key=$(git config user.signingkey 2> /dev/null || true)
  [[ -z "$key" || "$key" == ssh-* ]] && return 1
  key="${key/#\~/$HOME}"
  key="${key%.pub}"
  [[ -f "$key" ]] || return 1
  printf '%s\n' "$key"
}

# Prints ok / denied / unreachable. github.com refuses shells, so a
# *successful* auth exits 1 with a greeting on stderr — the exit status is
# useless and only the message is meaningful. BatchMode stops a
# passphrase-protected or absent key from hanging on a prompt during an
# otherwise unattended bootstrap. "unreachable" has to be its own answer
# rather than collapsing into a failure, because a DNS hiccup or captive
# portal would otherwise look identical to "no keys yet" and send a working
# machine down the generate-and-repin path.
github-ssh-status() {
  local out
  out=$(ssh -T -o BatchMode=yes -o ConnectTimeout=5 \
    -o StrictHostKeyChecking=accept-new git@github.com 2>&1)
  case "$out" in
    *"successfully authenticated"*) printf 'ok\n' ;;
    *"Permission denied"* | *"publickey"*) printf 'denied\n' ;;
    *) printf 'unreachable\n' ;;
  esac
}

# allowed_signers maps git author emails to the signing key so git can verify
# SSH-signed commits locally (git log --show-signature). The tracked gitconfig
# points gpg.ssh.allowedSignersFile here. Keyed off the pubkey passed in so
# this always records the key git really signs with — listing a different one
# makes every local commit read as unverifiable.
sync-allowed-signers() {
  local pub="$1"
  local extra_email="${2:-}"
  [[ -f "$pub" ]] || return 0

  local signers="$HOME/.ssh/allowed_signers"
  local signing_pub
  signing_pub=$(cut -d' ' -f1-2 "$pub")
  local git_email signer_email
  git_email=$(git config user.email 2> /dev/null || true)
  for signer_email in "$git_email" "$extra_email"; do
    [[ -z "$signer_email" ]] && continue
    if ! grep -qsF "$signer_email $signing_pub" "$signers"; then
      echo "$signer_email $signing_pub" >> "$signers"
    fi
  done
}

setup-ssh() {
  substep "Setting up SSH keys..."

  if [[ ! -d $HOME/.ssh ]]; then
    mkdir $HOME/.ssh
    chmod 700 $HOME/.ssh
  fi

  # Machines provisioned before the three-key layout below carry a single
  # id_ed25519 that GitHub already knows for both auth and signing. That is a
  # working setup, and treating it as "unconfigured" is actively destructive:
  # it prompts for an email, pushes redundant keys to GitHub, and — via the
  # github.conf Include — pins an IdentityFile this machine doesn't have with
  # IdentitiesOnly, breaking GitHub SSH until the new key is uploaded. So
  # probe for a working setup first and leave it entirely alone.
  local existing_signing_key ssh_status
  existing_signing_key=$(signing-key-path || true)
  if [[ -n "$existing_signing_key" ]]; then
    ssh_status=$(github-ssh-status)
    case "$ssh_status" in
      ok)
        unchanged "keys already work"
        sync-allowed-signers "$existing_signing_key.pub"
        return
        ;;
      unreachable)
        warn "Couldn't reach github.com to verify SSH auth — leaving the existing keys alone."
        sync-allowed-signers "$existing_signing_key.pub"
        return
        ;;
    esac
  fi

  # Three keys: a general-purpose one, plus dedicated GitHub auth and signing
  # keys. The tracked gitconfig signs commits over SSH, and the tracked
  # ~/.config/ssh/github.conf pins the auth key for github.com.
  local missing=()
  local key
  for key in id_ed25519 github_auth github_signing; do
    [[ -f $HOME/.ssh/$key ]] || missing+=("$key")
  done

  local email="${SSH_EMAIL:-}"
  [[ ${#missing[@]} -gt 0 ]] && _step_close # gum input / ssh-keygen prompt
  if [[ ${#missing[@]} -gt 0 && -z "$email" ]]; then
    email=$(gum input --prompt "What is your email for your ssh keys? " --placeholder "your_email@example.com")
    [[ $? -ne 0 || -z "$email" ]] && on-interrupt
  fi

  for key in "${missing[@]}"; do
    local comment="$email"
    case "$key" in
      github_auth) comment="$email (github auth)" ;;
      github_signing) comment="$email (github signing)" ;;
    esac
    ssh-keygen -t ed25519 -C "$comment" -f "$HOME/.ssh/$key"
  done

  # Record whichever key gitconfig points at, falling back to the one we just
  # generated. These can disagree — gitconfig still names id_ed25519 while
  # this function generates github_signing — and following gitconfig keeps
  # allowed_signers matching the key that actually produces the signatures.
  sync-allowed-signers \
    "$(signing-key-path || echo "$HOME/.ssh/github_signing").pub" "$email"

  # ~/.ssh can't be stowed (generated keys would land inside the repo), so the
  # tracked GitHub host config lives at ~/.config/ssh/github.conf and gets
  # wired in with an Include at the top of ~/.ssh/config. github.conf sets
  # IdentitiesOnly against ~/.ssh/github_auth, so including it without that key
  # present locks us out of github.com entirely — never wire it in blind.
  local sshconf="$HOME/.ssh/config"
  local include_line="Include ~/.config/ssh/github.conf"
  if [[ -f $HOME/.ssh/github_auth ]] && ! grep -qsxF "$include_line" "$sshconf"; then
    substep "Wiring tracked GitHub ssh config into ~/.ssh/config..."
    {
      echo "$include_line"
      [[ -f "$sshconf" ]] && cat "$sshconf"
    } > "$sshconf.juliet-tmp"
    mv "$sshconf.juliet-tmp" "$sshconf"
    chmod 600 "$sshconf"
  fi

  # Upload freshly generated GitHub keys via gh when possible. gh needs the
  # admin:public_key / admin:ssh_signing_key scopes, which the default login
  # doesn't grant — fall back to instructions if the add is rejected.
  if [[ ${#missing[@]} -gt 0 ]]; then
    local uploaded=true
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
      for key in "${missing[@]}"; do
        case "$key" in
          github_auth)
            gh ssh-key add "$HOME/.ssh/github_auth.pub" --type authentication --title "$(hostname) auth" || uploaded=false
            ;;
          github_signing)
            gh ssh-key add "$HOME/.ssh/github_signing.pub" --type signing --title "$(hostname) signing" || uploaded=false
            ;;
        esac
      done
    else
      uploaded=false
    fi
    if [[ "$uploaded" == "false" ]]; then
      bootstrap_error "Couldn't upload new SSH keys to GitHub automatically. To fix:" \
        "gh auth refresh -h github.com -s admin:public_key -s admin:ssh_signing_key" \
        "gh ssh-key add ~/.ssh/github_auth.pub --type authentication" \
        "gh ssh-key add ~/.ssh/github_signing.pub --type signing"
    fi
  fi
  unchanged "already set up"
}

setup-gpg() {
  if [[ ! -d $HOME/.gnupg ]]; then
    substep "Setting up GPG..."
    mkdir ~/.gnupg
    touch ~/.gnupg/gpg-agent.conf
    echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
  fi
}

setup-cyberduck() {
  # macOS-only. Cyberduck offers every identity in the SSH agent, which trips
  # strict servers' MaxAuthTries (and fail2ban) before the right key is tried.
  # Tell it to ignore the agent and use only the key set per-bookmark instead.
  if ! is-macos; then
    return
  fi

  if [[ ! -d "/Applications/Cyberduck.app" && ! -d "$HOME/Applications/Cyberduck.app" ]]; then
    return
  fi

  substep "Configuring Cyberduck SSH keys..."
  if [[ "$(defaults read ch.sudo.cyberduck ssh.authentication.agent.enable 2> /dev/null)" == "0" ]]; then
    unchanged "already configured"
    return
  fi
  defaults write ch.sudo.cyberduck ssh.authentication.agent.enable -bool false
}

setup-cyberduck-applicable() { is-macos; }
