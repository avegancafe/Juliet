# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# packages: Homebrew (macOS), DNF + COPRs and Flatpak (Fedora).

category packages rlog "📦 Installing system packages..." \
  "Install system packages from the Brewfile / DNFfile / Flatpakfile?" \
  setup-brew setup-dnf setup-flatpak setup-brew-taps

# Install Homebrew and wire it into PATH if it isn't already available.
ensure-brew() {
  if command -v brew &> /dev/null; then
    return
  fi

  rlog "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

  # Set up brew path based on OS
  if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    # Linux
    BREW_SHELLENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    if ! grep -q "linuxbrew" "$HOME/.bashrc" 2>/dev/null; then
      echo "$BREW_SHELLENV" >> "$HOME/.bashrc"
    fi
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    # macOS
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

# trust-brewfile-entries covers the taps the Brewfile still asks for, but a tap
# that was dropped from the Brewfile (or tapped by hand once) stays cloned
# forever, and Homebrew 7 warns about every such untrusted tap on *every* brew
# command. Trusting them would be wrong — nothing here wants them — so prune
# them instead, which is also what keeps the machine's tap list matching the
# Brewfile rather than accumulating whatever was ever tried.
prune-undeclared-taps() {
  local brewfile="$JULIET_BREWFILE"
  [[ -f "$brewfile" ]] || return 0

  local declared installed installed_names
  declared=$(sed -nE 's/^[[:space:]]*tap[[:space:]]+"([^"]+)".*/\1/p' "$brewfile")
  # `brew list --full-name` names casks with their tap too (basecamp/tap/hey,
  # sanyam-g/switch/switch) — a cask from homebrew/cask is bare (cmux) — so
  # ownership checks work the same for both package kinds.
  installed_names=$(brew list --full-name 2> /dev/null)

  for installed in $(brew tap); do
    # Official taps are trusted implicitly and get tapped as a side effect of
    # other brew commands — never prune those.
    [[ "$installed" == homebrew/* ]] && continue
    printf '%s\n' "$declared" | grep -qxF "$installed" && continue

    # Untapping a tap that owns an installed formula or cask orphans it, so
    # leave those be and say so.
    if printf '%s\n' "$installed_names" | grep -q "^$installed/"; then
      warn "Tap $installed isn't in the Brewfile but still owns installed packages — left alone."
      continue
    fi

    # A cask that MOVED taps is the one case `brew untap` can't classify: cmux
    # migrated from manaflow-ai/cmux to homebrew/cask, so no installed full
    # name matches the old tap's token anymore — but untap still matches the
    # installed cask by bare token, loads the tap's stale copy to check whether
    # it's installed (which the trust gate refuses; jq is in both the Brewfile
    # and the DNFfile), and, even trusted, would refuse non-interactively or
    # uninstall the installed cask with --force because it believes the tap
    # owns it. Nothing of the tap's is actually installed, so delete the
    # directory untap would have deleted instead. No keg links, manpages, or
    # completions need cleaning up: the ownership check above already ruled out
    # installed formulae, and no installed full name matches a tap token.
    local token name phantom=""
    if command -v jq &> /dev/null; then
      while IFS= read -r token; do
        [[ -n "$token" ]] || continue
        name="${token##*/}"
        printf '%s\n' "$installed_names" | grep -qE "(^|/)$name\$" || continue
        printf '%s\n' "$installed_names" | grep -qxF "$token" && continue
        phantom=1
      done < <(brew tap-info --json=v1 "$installed" 2> /dev/null | jq -r '.[0].cask_tokens[]?')
    fi

    if [[ -n "$phantom" ]]; then
      local tap_path
      tap_path=$(brew --repository "$installed" 2> /dev/null || true)
      spin "Removing the obsolete $installed tap (its casks live in another tap)..." \
        rm -rf "$tap_path" \
        || bootstrap_error "Failed to remove the obsolete $installed tap." \
          "Remove its directory by hand: $tap_path"
      rmdir "$(dirname "$tap_path")" 2> /dev/null || true
      if brew tap | grep -qxF "$installed"; then
        bootstrap_error "The obsolete $installed tap is still installed." \
          "Remove its directory by hand: $tap_path"
      fi
      continue
    fi

    spin "Untapping unused $installed..." brew untap "$installed" \
      || bootstrap_error "Failed to untap $installed." \
        "Run: brew untap $installed"
  done
}

# Homebrew 6.0 refuses to load formulae and casks from third-party taps until
# they're explicitly trusted, so `brew bundle` hard-fails on any tap-qualified
# Brewfile entry ("Refusing to load formula ... from untrusted tap"). Grant
# that trust up front, deriving the list from the Brewfile itself so a newly
# added entry can't reintroduce the failure, and scoping each grant to the one
# formula the Brewfile actually asks for rather than to the whole tap — the
# error message suggests either, but whole-tap trust also covers every future
# formula that tap ever publishes.
trust-brewfile-entries() {
  # Pre-6.0 Homebrew has no trust model and no such subcommand.
  local already
  already=$(brew trust --json v1 2> /dev/null) || return 0

  local brewfile="$JULIET_BREWFILE"
  [[ -f "$brewfile" ]] || return 0

  local kind name tap flag
  while read -r kind name; do
    [[ -z "$name" ]] && continue
    # The Brewfile keyword and the trust flag disagree: a `brew` line names a
    # formula, so it needs --formula, not --brew.
    case "$kind" in
      brew) flag="--formula" ;;
      cask) flag="--cask" ;;
      *) continue ;;
    esac
    # Skip anything already granted, either by name or by a broader whole-tap
    # grant, so repeat runs stay silent.
    tap="${name%/*}"
    grep -qF "\"$name\"" <<< "$already" && continue
    grep -qF "\"$tap\"" <<< "$already" && continue
    substep "Trusting $name (third-party tap)..."
    brew trust "$flag" "$name" \
      || bootstrap_error "Failed to trust $name." \
        "Retry manually: brew trust $flag $name"
  done < <(sed -nE 's#^[[:space:]]*(brew|cask)[[:space:]]+"([^"/]+/[^"/]+/[^"]+)".*#\1 \2#p' "$brewfile")
}

# Clear the module conflicts that make `brew bundle` report install failures on
# an otherwise healthy machine — both are one-time leftovers of how a tool was
# installed before the Brewfile asked for it, and a bundle that runs into one
# marks the whole entry failed.
clear-npm-codex-shadow() {
  grep -qE '^[[:space:]]*cask[[:space:]]*"codex"' "$JULIET_BREWFILE" 2> /dev/null || return 0

  # Machines that predate the codex cask carry the CLI as an npm-global
  # @openai/codex, and the cask cannot link over a binary no formula owns ("It
  # seems there is already a Binary at '/opt/homebrew/bin/codex'"). The cask is
  # the source of truth now — it's what the Brewfile updates — so remove the
  # npm copy. Homebrew's own npm has to do it: nodenv's would uninstall from
  # its own prefix, not /opt/homebrew/lib where this copy actually lives.
  local bin
  bin=$(readlink "$(brew --prefix)/bin/codex" 2> /dev/null || true)
  [[ "$bin" == *"/node_modules/@openai/codex/"* ]] || return 0

  local npm
  npm="$(brew --prefix node)/bin/npm"
  if [[ ! -x "$npm" ]]; then
    bootstrap_error "npm-global codex is blocking the Brewfile's codex cask." \
      "Remove it, then re-run: npm uninstall -g @openai/codex"
    return
  fi

  spin "Removing the npm-global codex (the cask owns the CLI now)..." \
    "$npm" uninstall -g @openai/codex \
    || bootstrap_error "Failed to remove the npm-global codex." \
      "Run: npm uninstall -g @openai/codex"
}

# `thrift` (Apache Thrift, a library dependency of apache-arrow/gdal) and
# `fbthrift` (declared in the Brewfile; watchman -> edencommon pulls it in) both
# install a `bin/thrift`. Homebrew only links one, so installing fbthrift
# aborts its link step on the symlink thrift already owns ("Could not symlink
# bin/thrift ... belonging to thrift") and `brew bundle` reports the whole
# entry as failed even though the keg itself is fine. The Brewfile is the
# source of truth for what this machine runs, so fbthrift keeps the name:
# unlink the dependency's copy — its libraries stay installed, which is all
# apache-arrow/gdal link against — before bundle links fbthrift.
resolve-thrift-link-conflict() {
  brew list --formula thrift &> /dev/null || return 0
  grep -qE '^[[:space:]]*brew[[:space:]]*"fbthrift"' "$JULIET_BREWFILE" 2> /dev/null || return 0

  local target
  target=$(readlink "$(brew --prefix)/bin/thrift" 2> /dev/null || true)
  [[ "$target" == *"/Cellar/thrift/"* ]] || return 0

  spin "Unlinking thrift so the Brewfile's fbthrift can own bin/thrift..." brew unlink thrift \
    || bootstrap_error "Failed to unlink thrift." \
      "Run: brew unlink thrift"

  # fbthrift may not be installed yet; bundle installs and links it right
  # after, which is exactly what the unlink above makes possible.
  if brew list --formula fbthrift &> /dev/null; then
    spin "Linking fbthrift..." brew link fbthrift \
      || bootstrap_error "Failed to link fbthrift." \
        "Run: brew link --overwrite fbthrift"
  fi
}

setup-brew() {
  ensure-brew

  if ! command -v gum &> /dev/null; then
    brew install gum
  fi

  # ~3s of brew queries that usually find nothing to fix — keep a spinner up.
  substep "Checking Homebrew taps and links..."
  trust-brewfile-entries
  prune-undeclared-taps
  clear-npm-codex-shadow
  resolve-thrift-link-conflict
  unchanged "nothing to fix"

  run-brew-bundle
}

# Touch ID for sudo, via /etc/pam.d/sudo_local — the macOS-sanctioned hook that
# survives OS updates (/etc/pam.d/sudo itself is reset by them). Lets the one
# sudo prompt before brew bundle be a fingerprint instead of a password.
setup-touchid-sudo() {
  is-macos || return
  local conf=/etc/pam.d/sudo_local
  substep "Enabling Touch ID for sudo..."
  if grep -qE '^[[:space:]]*auth[[:space:]]+sufficient[[:space:]]+pam_tid\.so' "$conf" 2> /dev/null; then
    unchanged "already enabled"
    return
  fi
  printf '%s\n' \
    "# sudo_local: managed by juliet-bootstrap (setup-touchid-sudo)" \
    "auth       sufficient     pam_tid.so" \
    | sudo tee "$conf" > /dev/null \
    || bootstrap_error "Failed to enable Touch ID for sudo" \
      "Add 'auth sufficient pam_tid.so' to $conf manually"
}

# Set while brew bundle runs, so on-interrupt can point at the log.
BREW_BUNDLE_LOG=""

# brew bundle behind a spinner, its output captured to a temp log. sudo is
# authenticated once up front (Touch ID) and kept alive in the background: the
# pkg-installer casks (gpg-suite, karabiner-elements) sudo mid-run, and a
# prompt hidden under the spinner would just hang.
run-brew-bundle() {
  local brewfile="$JULIET_BREWFILE"
  substep "Checking Brewfile..."
  if brew bundle check --file "$brewfile" &> /dev/null; then
    unchanged "everything installed"
    return
  fi

  setup-touchid-sudo
  local keepalive=""
  # Touch ID asks through a macOS dialog, not the terminal — say so, or this
  # looks like a hang.
  command sudo -n true 2> /dev/null \
    || substep "Waiting for sudo (Touch ID or password) so casks can install"
  if sudo -v; then
    # Refresh the sudo timestamp until brew bundle is done.
    (while kill -0 $$ 2> /dev/null; do sudo -n true 2> /dev/null; sleep 30; done) &
    keepalive=$!
    disown "$keepalive" # no "Terminated" job notice when we kill it below
  else
    warn "sudo not authenticated — casks that need it may fail."
  fi

  BREW_BUNDLE_LOG="$(mktemp "${TMPDIR:-/tmp}/juliet-brew-bundle.XXXXXX")"
  local rc=0
  spin "Running brew bundle..." \
    bash -c 'exec brew bundle --file "$1" > "$2" 2>&1 < /dev/null' _ "$brewfile" "$BREW_BUNDLE_LOG" \
    || rc=$?
  [[ -n "$keepalive" ]] && kill "$keepalive" 2> /dev/null

  # Ctrl-C normally reaches on-interrupt (which prints the log path) via the
  # INT trap; 130 here covers the command exiting from SIGINT on its own.
  if [[ $rc -eq 130 ]]; then
    on-interrupt
  elif [[ $rc -eq 0 ]]; then
    rm -f "$BREW_BUNDLE_LOG"
  else
    tail -n 20 "$BREW_BUNDLE_LOG" | sed 's/^/      /' >&2
    bootstrap_error "brew bundle reported failures." \
      "Full output: $BREW_BUNDLE_LOG" \
      "Then re-run: juliet-bootstrap --enable=packages"
  fi
  BREW_BUNDLE_LOG=""
}

# Every enabled COPR is consulted on every dnf transaction, so a copr that
# stops building for this Fedora release becomes a 404 banner on *every* dnf
# command: solopasha/hyprland dropped all of its stable chroots (rawhide only
# now) once Hyprland itself landed in Fedora, and nothing here noticed because
# the repo file stays enabled forever once `dnf copr enable` has run.
#
# So the DNFfile's `copr` lines are the source of truth in both directions:
# every declared copr gets enabled (and checked for a build for this release),
# and every enabled copr the DNFfile no longer declares gets removed — after
# moving any package still installed from it onto whatever the remaining repos
# offer, so pruning a stale copr can't strand its packages.
sync-copr-repos() {
  local dnffile="$1"
  local declared repo release arch enabled owned pkg missing repofile ids id
  local -a disable

  declared=$(sed -nE 's/^copr[[:space:]]+([^[:space:]]+).*/\1/p' "$dnffile")
  release=$(rpm -E %fedora)
  arch=$(uname -m)

  for repo in $declared; do
    if ! dnf copr list 2> /dev/null | grep -q "^copr.fedorainfracloud.org/$repo\( \|$\)"; then
      rlog "Enabling COPR: $repo"
      sudo dnf copr enable -y "$repo" \
        || bootstrap_error "Failed to enable COPR $repo." \
          "Run: sudo dnf copr enable $repo"
    fi

    # Name the broken copr ourselves rather than leaving the user to decode
    # dnf's "Status code: 404 for .../repomd.xml" on every later command.
    if ! curl -sfLI -o /dev/null \
      "https://download.copr.fedorainfracloud.org/results/$repo/fedora-$release-$arch/repodata/repomd.xml"; then
      warn "COPR $repo has no fedora-$release-$arch build — dnf will 404 on it until the DNFfile points somewhere that does."
    fi
  done

  # `dnf copr list` prints "copr.fedorainfracloud.org/<owner>/<project>", plus a
  # trailing "[eternal_deps]" marker for a copr that dragged in a dependency
  # repo of its own (those dep repos are removed along with their parent).
  for enabled in $(dnf copr list 2> /dev/null | awk '{print $1}' \
    | sed 's|^copr.fedorainfracloud.org/||'); do
    printf '%s\n' "$declared" | grep -qxF "$enabled" && continue
    # Hardware-gated coprs that setup-fingerprint owns.
    if has-goodix-533c && printf '%s\n' "${FINGERPRINT_COPRS[@]}" | grep -qxF "$enabled"; then
      continue
    fi

    # One copr can own several repo ids: its own
    # copr:copr.fedorainfracloud.org:<owner>:<project>, plus a
    # coprdep:...:<owner>:<other> section per dependency repo it pulled in
    # (avengemedia/dms carries avengemedia/danklinux that way, and that is
    # where cliphist and matugen actually come from). They all live in the one
    # .repo file that `dnf copr remove` deletes, so read the ids out of it
    # rather than guessing from the copr name.
    repofile="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:${enabled%/*}:${enabled#*/}.repo"
    ids=$(sed -nE 's/^\[(.+)\]$/\1/p' "$repofile" 2> /dev/null)
    if [[ -z "$ids" ]]; then
      ids="copr:copr.fedorainfracloud.org:${enabled%/*}:${enabled#*/}"
    fi

    owned=$(dnf repoquery --installed --qf '%{name} %{from_repo}\n' 2> /dev/null \
      | grep -F -f <(printf '%s\n' "$ids" | sed 's/^/ /') | awk '{print $1}')

    if [[ -n "$owned" ]]; then
      disable=()
      for id in $ids; do
        disable+=(--disablerepo="$id")
      done
      missing=""
      for pkg in $owned; do
        dnf repoquery --assumeyes "${disable[@]}" --available \
          --qf '%{name}\n' "$pkg" 2> /dev/null | grep -qx "$pkg" || missing="$missing $pkg"
      done

      if [[ -n "$missing" ]]; then
        warn "COPR $enabled is not in the DNFfile but is the only source of:$missing — left enabled."
        warn "Declare it in the DNFfile (or drop those packages) to settle it."
        continue
      fi
    fi

    substep "Removing COPR $enabled (not declared in the DNFfile)..."
    sudo dnf copr remove -y "$enabled" \
      || bootstrap_error "Failed to remove COPR $enabled." \
        "Run: sudo dnf copr remove $enabled"
  done

  rehome-orphaned-copr-packages
}

# A package installed from a copr that no longer exists on the system keeps
# working, but it stays pinned to a version no enabled repo knows about: dnf
# won't upgrade it, and `dnf install <pkg>` sees it as already satisfied. So
# sweep for them by from_repo (this is deliberately not folded into the prune
# above: a run interrupted between removing a copr and re-homing its packages
# would otherwise leave them stranded forever, since the repo it keyed off is
# already gone) and distro-sync each onto whichever enabled repo provides it.
rehome-orphaned-copr-packages() {
  local enabled_ids orphans stranded rehome pkg

  enabled_ids=$(dnf repolist --enabled 2> /dev/null | tail -n +2 | awk '{print $1}')
  orphans=$(dnf repoquery --installed --qf '%{name} %{from_repo}\n' 2> /dev/null \
    | grep -E '^[^ ]+ copr(dep)?:' \
    | while read -r pkg id; do
      printf '%s\n' "$enabled_ids" | grep -qxF "$id" || echo "$pkg"
    done)
  [[ -z "$orphans" ]] && return

  # distro-sync errors out on a package nothing provides any more, which would
  # take the packages that *can* be re-homed down with it.
  rehome=""
  stranded=""
  for pkg in $orphans; do
    if dnf repoquery --assumeyes --available --qf '%{name}\n' "$pkg" 2> /dev/null | grep -qx "$pkg"; then
      rehome="$rehome $pkg"
    else
      stranded="$stranded $pkg"
    fi
  done

  if [[ -n "$stranded" ]]; then
    warn "Installed but no longer in any enabled repo:$stranded"
    warn "Declare a copr that ships them in the DNFfile, or remove them."
  fi

  if [[ -n "$rehome" ]]; then
    substep "Re-homing$rehome onto the enabled repos..."
    sudo dnf distro-sync -y $rehome \
      || bootstrap_error "Failed to re-home packages from a removed copr:$rehome" \
        "Run: sudo dnf distro-sync$rehome"
  fi
}

# A DNFfile entry may be satisfied by a differently-named package: Fedora 44
# ships node only as versioned streams (nodejs -> nodejs22 via a virtual
# provide), kubernetes-client -> kubernetes1.36-client, and dnf resolves
# deno -> deno-bin through /usr/bin/deno binary provides. Checking only
# `rpm -q <name>` misses all of these, so those entries got "retried"
# (and reported failed on any transient dnf error) on every single run.
dnf-satisfied() {
  rpm -q "$1" &> /dev/null && return 0
  rpm -q --whatprovides "$1" &> /dev/null && return 0
  # Binary/file provides need dnf's resolver; --assumeno exits 0 only when
  # the spec is already satisfied. --cacheonly keeps this fast and offline; with
  # no cache yet it fails, which just means the spec gets handed to dnf.
  dnf --cacheonly install --assumeno "$1" &> /dev/null
}

setup-dnf() {
  substep "Setting up DNF packages..."

  if ! command -v gum &> /dev/null; then
    sudo dnf install -y gum
  fi

  DNFFILE="$JULIET_DNFFILE"
  if [[ ! -f "$DNFFILE" ]]; then
    warn "DNFfile not found at $DNFFILE"
    return
  fi

  # Enable RPM Fusion (free + nonfree) first: some DNFfile packages (e.g.
  # steam) only exist there and would otherwise be silently skipped by
  # --skip-unavailable.
  if ! rpm -q rpmfusion-free-release &> /dev/null || ! rpm -q rpmfusion-nonfree-release &> /dev/null; then
    rlog "Enabling RPM Fusion repositories..."
    sudo dnf install -y \
      "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
  fi

  # Enable the declared COPRs (and retire undeclared ones) first
  sync-copr-repos "$DNFFILE"

  # Collect packages
  packages=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines, comments, and copr lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# || "$line" =~ ^copr[[:space:]]+ ]] && continue
    packages+=("$line")
  done < "$DNFFILE"

  # Only hand dnf what's missing, so a machine that's already converged doesn't
  # prompt for sudo just to hear "Nothing to do".
  missing=()
  for pkg in ${packages[@]+"${packages[@]}"}; do
    dnf-satisfied "$pkg" || missing+=("$pkg")
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    unchanged "all ${#packages[@]} installed"
    return
  fi

  # Install packages
  if [[ ${#missing[@]} -gt 0 ]]; then
    rlog "Installing ${#missing[@]} DNF packages..."
    # --skip-unavailable/--skip-broken keep one bad package (e.g. steam
    # without RPM Fusion) from aborting the whole transaction.
    sudo dnf install -y --skip-unavailable --skip-broken "${missing[@]}"

    # Retry anything still missing individually so each failure surfaces its
    # own error instead of being silently skipped.
    failed=()
    for pkg in "${missing[@]}"; do
      dnf-satisfied "$pkg" && continue
      substep "Retrying $pkg individually..."
      sudo dnf install -y "$pkg" || failed+=("$pkg")
    done
    if [[ ${#failed[@]} -gt 0 ]]; then
      bootstrap_error "Failed to install DNF packages: ${failed[*]}" \
        "Install them manually, then re-run: juliet-bootstrap --enable=packages"
    fi
  fi
}

setup-flatpak() {
  substep "Setting up Flatpak packages..."

  FLATPAKFILE="$JULIET_FLATPAKFILE"
  if [[ ! -f "$FLATPAKFILE" ]]; then
    warn "Flatpakfile not found at $FLATPAKFILE"
    return
  fi

  # Add remotes first
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^remote[[:space:]]+ ]]; then
      read -r _ name url <<< "$line"
      flatpak remotes --columns=name 2> /dev/null | grep -qxF "$name" && continue
      substep "Adding Flatpak remote: $name"
      flatpak remote-add --if-not-exists "$name" "$url"
    fi
  done < "$FLATPAKFILE"

  # Install apps. Close the step first so per-app lines nest under it.
  _step_close
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# || "$line" =~ ^remote[[:space:]]+ ]] && continue
    if flatpak info "$line" &> /dev/null; then
      skip "Flatpak $line (already installed)"
      continue
    fi
    spin "Installing Flatpak: $line..." flatpak install -y flathub "$line" \
      || bootstrap_error "Failed to install Flatpak $line" \
        "Retry manually: flatpak install flathub $line"
  done < "$FLATPAKFILE"

  # Flatpak bind-mounts host font *files* into every sandbox, but not the host's
  # user fontconfig *config*. Without this, symlinked/config/fontconfig/fonts.conf
  # is invisible inside the sandbox and generic families (sans-serif, monospace)
  # fall back to the runtime's DejaVu instead of Iosevka Nerd Font Mono. Applies
  # globally so future Flatpaks inherit it. User-level; no root needed.
  if flatpak override --user --show 2> /dev/null | grep -qF 'xdg-config/fontconfig:ro'; then
    skip "Flatpak fontconfig access (already granted)"
    return
  fi
  substep "Granting Flatpaks read access to user fontconfig..."
  flatpak override --user --filesystem=xdg-config/fontconfig:ro \
    || warn "Could not set Flatpak fontconfig override — Flatpak apps will use DejaVu for generic families."
}

setup-brew-applicable() { is-macos; }

setup-dnf-applicable() { is-fedora; }

setup-flatpak-applicable() { is-fedora; }

# Homebrew isn't the package manager on Fedora, but it is still installed
# there (setup-cargo leans on brew's rust), so its taps need the same
# reconciliation or every brew command keeps warning.
setup-brew-taps-applicable() { is-fedora && command -v brew &> /dev/null; }

setup-brew-taps() {
  trust-brewfile-entries
  prune-undeclared-taps
}
