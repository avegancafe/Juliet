# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# claude: Claude Code CLI + plugins, statusline, Claude Desktop.

category claude rlog "🤖 Setting up Claude..." "Set up Claude?" \
  setup-claude-code setup-claude-statusline setup-claude-desktop

# claude-statusline renders the Claude Code status line (the `statusLine` block
# in symlinked/home/.claude/settings.json), reading
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
    "sentry@claude-plugins-official"
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
