# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# claude: Claude Code CLI + plugins, statusline, Claude Desktop.

category claude rlog "🤖 Setting up Claude..." "Set up Claude?" \
  setup-claude-code setup-claude-settings setup-claude-statusline setup-claude-desktop

# ~/.claude/settings.json is GENERATED, not stowed: Juliet's base
# (etc/claude/settings.json), then each extension's claude/settings.json
# fragment in JULIET_EXTENSION order, then ~/.config/local/claude/settings.json.
# Objects merge key by key, arrays (permissions.allow, …) are concatenated
# without duplicates, and anything else is replaced by the later layer. Claude
# Code has no user-level include, so one file is the only way for several
# layers (Juliet, a work extension, a personal one) to each add plugins.
#
# Claude Code writes to this file (plugin toggles, /config). Those edits are no
# longer committed anywhere: bootstrap remembers a hash of what it last wrote
# and, when the file has changed since, says which keys and asks before
# replacing it. Move the change into the layer it belongs in first.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_SETTINGS_HASH="$HOME/.local/state/juliet/claude-settings.sha256"
# shellcheck disable=SC2016  # jq program, not shell
CLAUDE_SETTINGS_MERGE='
  def uniq: reduce .[] as $x ([]; if any(.[]; . == $x) then . else . + [$x] end);
  def merge($a; $b):
    if ($a | type) == "object" and ($b | type) == "object" then
      reduce ($b | keys_unsorted[]) as $k ($a; .[$k] = merge($a[$k]; $b[$k]))
    elif ($a | type) == "array" and ($b | type) == "array" then ($a + $b) | uniq
    elif $b == null then $a
    else $b end;
  reduce .[1:][] as $layer (.[0]; merge(.; $layer))'

claude-settings-layers() {
  local dir
  printf '%s\n' "$JULIET_DIR/etc/claude/settings.json"
  for dir in ${EXTENSION_DIRS[@]+"${EXTENSION_DIRS[@]}"}; do
    [[ -f "$dir/claude/settings.json" ]] && printf '%s\n' "$dir/claude/settings.json"
  done
  [[ -f "$HOME/.config/local/claude/settings.json" ]] && printf '%s\n' "$HOME/.config/local/claude/settings.json"
  return 0
}

# A settings file's content hash, ignoring key order, formatting and state
# Claude Code keeps there (feedbackSurveyState).
# Prints nothing if the file isn't JSON or no hashing tool exists (shasum is
# perl, which a minimal Fedora may lack), so callers treat "" as unknown.
claude-settings-hash() {
  local norm
  norm=$(jq -S 'del(.feedbackSurveyState)' "$1" 2> /dev/null) || return 0
  if command -v sha256sum &> /dev/null; then
    printf '%s\n' "$norm" | sha256sum | cut -d' ' -f1
  elif command -v shasum &> /dev/null; then
    printf '%s\n' "$norm" | shasum -a 256 | cut -d' ' -f1
  fi
}

setup-claude-settings() {
  substep "Writing ~/.claude/settings.json..."
  local -a layers=()
  local layer
  while IFS= read -r layer; do layers+=("$layer"); done < <(claude-settings-layers)
  for layer in "${layers[@]}"; do
    if ! jq empty "$layer" 2> /dev/null; then
      bootstrap_error "$layer isn't valid JSON — not writing ~/.claude/settings.json." \
        "Fix it, then re-run: juliet-bootstrap --enable=claude"
      return 0
    fi
  done

  local out
  out=$(mktemp "${TMPDIR:-/tmp}/juliet-claude-settings.XXXXXX")
  jq -s "$CLAUDE_SETTINGS_MERGE" "${layers[@]}" > "$out" || {
    rm -f "$out"
    bootstrap_error "Merging the Claude settings layers failed." "Re-run with: juliet-bootstrap --enable=claude"
    return 0
  }

  mkdir -p "$HOME/.claude" "$(dirname "$CLAUDE_SETTINGS_HASH")"
  # An extension that still overrides the whole file (home/.claude/settings.json)
  # wins, as before; the old stowed symlink into Juliet gives way silently.
  if [[ -L "$CLAUDE_SETTINGS" ]]; then
    if [[ "$(readlink "$CLAUDE_SETTINGS")" == "$EXTENSIONS_ROOT/"* ]]; then
      rm -f "$out"
      skip "an extension replaces the whole file (home/.claude/settings.json)"
      return 0
    fi
    rm "$CLAUDE_SETTINGS"
  fi

  if [[ -f "$CLAUDE_SETTINGS" ]]; then
    local current last
    current=$(claude-settings-hash "$CLAUDE_SETTINGS")
    if [[ -n "$current" && "$current" == "$(claude-settings-hash "$out")" ]]; then
      printf '%s\n' "$current" > "$CLAUDE_SETTINGS_HASH"
      rm -f "$out"
      unchanged "up to date"
      return 0
    fi
    last=$(cat "$CLAUDE_SETTINGS_HASH" 2> /dev/null || true)
    # Pre-generation machines have no hash: their file was the stowed one.
    if [[ -n "$last" && "$current" != "$last" && "${CLAUDE_SETTINGS_PRE_HASH:-$current}" != "$last" ]]; then
      local keys
      keys=$(jq -rn --slurpfile a "$CLAUDE_SETTINGS" --slurpfile b "$out" \
        '[($a[0] + $b[0]) | keys[] | select($a[0][.] != $b[0][.])] - ["feedbackSurveyState"] | join(", ")')
      # shellcheck disable=SC2088
      warn "~/.claude/settings.json was changed outside Juliet (keys: ${keys:-?}). Regenerating drops those changes."
      warn "Keep one by adding it to etc/claude/settings.json, an extension's claude/settings.json, or ~/.config/local/claude/settings.json."
      if ! gum-confirm "Replace ~/.claude/settings.json anyway?"; then
        rm -f "$out"
        skip "kept the edited file"
        return 0
      fi
      cp "$CLAUDE_SETTINGS" "$CLAUDE_SETTINGS.pre-juliet.bak"
      notice "Previous file saved as ~/.claude/settings.json.pre-juliet.bak"
    fi
  fi
  mv -f "$out" "$CLAUDE_SETTINGS"
  chmod 644 "$CLAUDE_SETTINGS"
  claude-settings-hash "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS_HASH"
}

# claude-statusline renders the Claude Code status line (the `statusLine` block
# in etc/claude/settings.json), reading
# symlinked/config/claude-statusline/config.toml.
#
# We install OUR FORK, not upstream: it adds width-aware per-module priorities
# (rank a module with `priority = N` and it drops, with its separator, when the
# line won't fit COLUMNS) plus a `[fit] margin` knob. Upstream has neither.
#
# The fork's go.mod declares the fork's own module path, so a plain `go install`
# works. (It briefly kept upstream's path to stay PR-able upstream, which made
# the fork uninstallable by its own URL — Go resolves module identity from go.mod
# and rejects the mismatch. Ease of install won.)
#
# PINNED TO @main, AND NEITHER @latest NOR A BRANCH NAME. Two traps here:
#   1. `@latest` resolves to the newest *semver tag*, and the fork inherited
#      upstream's v0.7-v0.9 tags — so it installs a working binary silently
#      missing the priorities feature we forked for. Verified.
#   2. `go install pkg@some/branch` is rejected outright: "invalid version …
#      disallowed version string". Version queries can't contain a slash, so
#      feat/module-priorities is unusable here. The feature branch was
#      fast-forwarded into the fork's main to give a slash-free ref.
#
# No `command -v` guard: main moves, so re-running picks up new commits. The
# installed binary's pseudo-version ends in the commit it was built from, so
# compare that to main's tip and only reinstall when they differ. (First install
# of a new module path can be slow while proxy.golang.org fetches it.)
CLAUDE_STATUSLINE_PKG="github.com/avegancafe/claude-statusline"

CLAUDE_STATUSLINE_REF="main"

setup-claude-statusline() {
  if ! command -v go &> /dev/null; then
    bootstrap_error "go not found — cannot install claude-statusline." \
      "Fedora: the 'golang' DNFfile entry. macOS: 'brew \"go\"' in the Brewfile." \
      "Then re-run: juliet-bootstrap --enable=claude"
    return
  fi

  # Homebrew's felipeelias/tap/claude-statusline is the upstream this fork came
  # from, and it installs the same binary name into /opt/homebrew/bin — which
  # sits ahead of ~/go/bin on PATH. Since the tracked settings.json invokes a
  # bare `claude-statusline prompt`, leaving the formula installed silently
  # runs upstream instead of the fork, and the fork-only config keys in the
  # tracked config.toml render as "(statusline error)". Deliberately kept out
  # of the Brewfile, so remove it rather than letting it win.
  if command -v brew &> /dev/null && brew list --formula claude-statusline &> /dev/null; then
    spin "Removing the conflicting Homebrew claude-statusline (shadows the fork)..." \
      brew uninstall --formula claude-statusline \
      || bootstrap_error "Couldn't remove the Homebrew claude-statusline — it will keep shadowing the fork on PATH." \
        "Remove it manually: brew uninstall claude-statusline"
  fi

  # GOPRIVATE bypasses proxy.golang.org and the checksum DB for this module only.
  # Without it, `@main` is served from the proxy's cached branch resolution, which
  # lags behind the real tip — observed installing a commit old enough to predate
  # a field the tracked config.toml references, producing "(statusline error)" with
  # a green exit. A personal fork wants the direct fetch.
  local gobin installed_sha remote_sha
  gobin="$(go env GOBIN)"
  [[ -n "$gobin" ]] || gobin="$(go env GOPATH)/bin"
  installed_sha=$(go version -m "$gobin/claude-statusline" 2> /dev/null \
    | awk '$1 == "mod" { n = split($3, v, "-"); print v[n] }')
  remote_sha=$(git ls-remote "https://${CLAUDE_STATUSLINE_PKG}" "refs/heads/${CLAUDE_STATUSLINE_REF}" 2> /dev/null \
    | cut -c1-12)
  if [[ -n "$installed_sha" && "$installed_sha" == "$remote_sha" ]]; then
    skip "claude-statusline (up to date at ${installed_sha:0:7})"
    return
  fi

  spin "Installing claude-statusline (${CLAUDE_STATUSLINE_REF})..." \
    env GOPRIVATE='github.com/avegancafe/*' go install "${CLAUDE_STATUSLINE_PKG}@${CLAUDE_STATUSLINE_REF}" \
    || bootstrap_error "Failed to install claude-statusline — the Claude Code status line will render nothing." \
      "Retry manually: go install ${CLAUDE_STATUSLINE_PKG}@${CLAUDE_STATUSLINE_REF}"
}

setup-claude-code() {
  # Plugin installs below write to settings.json; remember what it held
  # before them so setup-claude-settings doesn't mistake that for a hand edit.
  CLAUDE_SETTINGS_PRE_HASH=""
  [[ -f "$CLAUDE_SETTINGS" && ! -L "$CLAUDE_SETTINGS" ]] \
    && CLAUDE_SETTINGS_PRE_HASH=$(claude-settings-hash "$CLAUDE_SETTINGS")
  if ! command -v claude &> /dev/null; then
    rlog "Installing Claude CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
  else
    skip "Claude CLI already installed"
  fi

  # Configure git to authenticate GitHub over HTTPS via the gh CLI. Claude Code
  # clones marketplaces/plugins over HTTPS, so private ones (e.g. the
  # avegancafe-marketplace referenced in settings.json) fail to clone without an
  # HTTPS credential helper. We write it to the machine-local gitconfig (included
  # by the tracked ~/.gitconfig) rather than running `gh auth setup-git`, which
  # would bake a machine-specific absolute gh path into the tracked dotfile. The
  # `!gh ...` form resolves gh from PATH, so it stays portable across macOS/Fedora.
  if command -v gh &> /dev/null; then
    local local_gitconfig="$HOME/.config/local/gitconfig" helper="!gh auth git-credential"
    if [[ "$(git config --file "$local_gitconfig" --get credential."https://github.com".helper)" == "$helper" \
      && "$(git config --file "$local_gitconfig" --get credential."https://gist.github.com".helper)" == "$helper" ]]; then
      skip "gh git credential helper (already configured)"
    elif gh auth status &> /dev/null; then
      substep "Configuring gh as the GitHub git credential helper..."
      mkdir -p "$HOME/.config/local"
      git config --file "$HOME/.config/local/gitconfig" credential."https://github.com".helper "!gh auth git-credential"
      git config --file "$HOME/.config/local/gitconfig" credential."https://gist.github.com".helper "!gh auth git-credential"
    else
      warn "gh is installed but not authenticated — private plugin marketplaces won't clone over HTTPS."
      warn "Run 'gh auth login', then re-run: juliet-bootstrap --enable=claude"
    fi
  else
    warn "gh not found; skipping git credential-helper setup."
    warn "Private plugin marketplaces won't clone over HTTPS until gh is installed and authenticated."
  fi

  # Each `claude plugin ... list` costs ~0.5s, so list once and grep the
  # captured output, under a step so the wait isn't a frozen screen.
  substep "Checking Claude plugins..."
  local marketplace_list plugin_list
  marketplace_list=$(claude plugin marketplace list --json 2>/dev/null)
  plugin_list=$(claude plugin list 2>/dev/null)

  # Define marketplaces to add
  # Format: "name:id" pairs (bash 3.2 compatible)
  marketplaces=(
    "superpowers-marketplace:obra/superpowers-marketplace"
    "claude-plugins-official:anthropics/claude-plugins-official"
  )

  # Add marketplaces if not already registered. Match against --json output:
  # the default text listing also names claude.ai-hosted marketplaces that are
  # NOT configured ("... — not added"), so grepping the whole listing made
  # superpowers-marketplace look registered — its add was skipped and every
  # plugin install from it failed with "Plugin not found in marketplace".
  for marketplace_pair in "${marketplaces[@]}"; do
    marketplace_name="${marketplace_pair%%:*}"
    marketplace_id="${marketplace_pair#*:}"
    if ! printf '%s\n' "$marketplace_list" | grep -Fq "\"name\": \"$marketplace_name\""; then
      spin "Adding $marketplace_name marketplace..." claude plugin marketplace add "$marketplace_id" \
        || warn "Failed to add $marketplace_name marketplace (non-fatal)."
    fi
  done

  # Define plugins to install
  plugins=(
    "superpowers@superpowers-marketplace"
    "frontend-design@claude-plugins-official"
    "context7@claude-plugins-official"
    "linear@claude-plugins-official"
    "playwright@claude-plugins-official"
  )

  # Install plugins if not already installed
  for plugin in "${plugins[@]}"; do
    if ! printf '%s\n' "$plugin_list" | grep -Fq "$plugin"; then
      spin "Installing $plugin..." claude plugin install "$plugin" \
        || bootstrap_error "Failed to install $plugin — run 'claude plugin install $plugin' manually."
    fi
  done
  unchanged "all installed"
}

# Anthropic doesn't ship an official Fedora/RPM build of Claude Desktop — only
# a Debian/Ubuntu .deb. aaddrick/claude-desktop-debian repackages that .deb
# into an .rpm (plus a launcher for Linux-specific quirks) and publishes it via
# its own DNF repo, so this stays a real `dnf install`/`dnf upgrade` with an
# update path instead of a one-off hand-extracted .deb.
setup-claude-desktop() {
  if ! is-fedora; then
    return
  fi

  local repo_file="/etc/yum.repos.d/claude-desktop-unofficial.repo"
  if [[ ! -f "$repo_file" ]]; then
    substep "Adding the claude-desktop-unofficial DNF repo..."
    sudo curl -fsSL https://pkg.claude-desktop-debian.dev/rpm/claude-desktop-unofficial.repo -o "$repo_file" \
      || bootstrap_error "Failed to add the claude-desktop-unofficial repo" \
        "Add it manually: sudo curl -fsSL https://pkg.claude-desktop-debian.dev/rpm/claude-desktop-unofficial.repo -o $repo_file"
  fi

  if ! rpm -q claude-desktop-unofficial &> /dev/null; then
    substep "Installing Claude Desktop (claude-desktop-unofficial)..."
    sudo dnf install -y claude-desktop-unofficial \
      || bootstrap_error "Failed to install claude-desktop-unofficial" \
        "Install it manually: sudo dnf install -y claude-desktop-unofficial"
  fi
}

setup-claude-desktop-applicable() { is-fedora; }
