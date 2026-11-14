# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# dev: language toolchains and CLI dev tools.

category dev rlog "🛠️ Installing dev tools..." "Install dev tools?" \
  setup-cargo setup-rust setup-go-tools setup-python setup-nodenv setup-node-tools \
  setup-flyctl setup-beads setup-rex setup-rex-theme

setup-cargo() {
  substep "Checking cargo..."
  if ! command -v cargo &> /dev/null; then
    rlog "Installing Rust via rustup-init..."
    rustup-init
  fi

  # `brew bundle` installs a formula but never upgrades one already present, so
  # a long-lived machine keeps whatever rustc it first got while the crates in
  # setup-rust keep adopting new language features (libsqlite3-sys 0.38 needs
  # cfg_select, stable only after 1.92). The result is that every `cargo
  # install` below dies with an E0658 that reads like a broken crate rather
  # than a stale compiler — so keep brew's rust current before we build.
  if command -v brew &> /dev/null && brew list --formula rust &> /dev/null \
    && [[ -n "$(brew outdated --formula rust 2> /dev/null)" ]]; then
    spin "Upgrading rust (Homebrew)..." brew upgrade rust -y \
      || bootstrap_error "Failed to upgrade rust — run 'brew upgrade rust' manually."
  fi
  unchanged "up to date"
}

# lazysql via go install; macOS gets it from the Brewfile instead.
setup-go-tools-applicable() { is-fedora; }
setup-go-tools() {
  substep "Checking Go tools..."
  if ! command -v lazysql &> /dev/null; then
    spin "Installing lazysql (go)..." go install github.com/jorgerojas26/lazysql@latest \
      || bootstrap_error "Failed to install lazysql — run 'go install github.com/jorgerojas26/lazysql@latest' manually."
  fi
  unchanged "already installed"
}

setup-rust() {
  substep "Checking Rust tools..."
  if ! command -v stylua &> /dev/null; then
    spin "Installing stylua (cargo)..." cargo install stylua \
      || bootstrap_error "Failed to install stylua — run 'cargo install stylua' manually."
  fi

  if is-macos && ! command -v silicon &> /dev/null; then
    spin "Installing silicon (cargo)..." cargo install silicon \
      || bootstrap_error "Failed to install silicon — run 'cargo install silicon' manually."
  fi

  # tabiew (tw, used by the cq alias); macOS gets it from the Brewfile
  if is-fedora && ! command -v tw &> /dev/null; then
    spin "Installing tabiew (cargo)..." cargo install tabiew \
      || bootstrap_error "Failed to install tabiew — run 'cargo install tabiew' manually."
  fi
  unchanged "already installed"
}

setup-python() {
  substep "Checking Python tools..."
  if ! command -v poetry &> /dev/null; then
    spin "Installing poetry..." sh -c 'curl -sSL https://install.python-poetry.org | python3 -' \
      || bootstrap_error "Failed to install poetry" \
        "Retry manually: curl -sSL https://install.python-poetry.org | python3 -"
  fi

  # sqlfluff (neoformat's SQL formatter) has no Fedora dnf package; macOS gets
  # it from the Brewfile
  if is-fedora && ! command -v sqlfluff &> /dev/null; then
    spin "Installing sqlfluff (pip)..." pip install --user sqlfluff \
      || bootstrap_error "Failed to install sqlfluff — run 'pip install --user sqlfluff' manually."
  fi

  # pipenv (the pv alias) was dropped from Fedora's repos entirely; macOS gets
  # it from the Brewfile
  if is-fedora && ! command -v pipenv &> /dev/null; then
    spin "Installing pipenv (pip)..." pip install --user pipenv \
      || bootstrap_error "Failed to install pipenv — run 'pip install --user pipenv' manually."
  fi
  unchanged "already installed"
}

setup-node-tools() {
  substep "Checking Node tools..."
  # prettier/eslint (neoformat/nvim-lint) have no Fedora dnf packages; macOS
  # gets them from the Brewfile
  if is-fedora; then
    for tool in prettier eslint; do
      if ! command -v "$tool" &> /dev/null; then
        rlog "Installing $tool via npm..."
        sudo npm install -g "$tool" \
          || bootstrap_error "Failed to install $tool — run 'sudo npm install -g $tool' manually."
      fi
    done
  fi
  unchanged "already installed"
}

setup-nodenv() {
  # macOS gets nodenv from the Brewfile; Fedora has no dnf package, so use the
  # official installer (clones nodenv + node-build into ~/.nodenv).
  substep "Checking nodenv..."
  if command -v nodenv &> /dev/null || [[ -d "$HOME/.nodenv/bin" ]]; then
    unchanged "already installed"
    return
  fi
  spin "Installing nodenv..." sh -c 'curl -fsSL https://github.com/nodenv/nodenv-installer/raw/HEAD/bin/nodenv-installer | bash' \
    || bootstrap_error "Failed to install nodenv — see https://github.com/nodenv/nodenv-installer."
}

setup-flyctl() {
  # macOS gets flyctl from the Brewfile; Fedora has no dnf package, so use
  # Fly's official installer (binary + `fly` symlink in ~/.fly/bin, which
  # env.fish puts on PATH). Run non-interactively it leaves shell rc files alone.
  substep "Checking flyctl..."
  if command -v flyctl &> /dev/null || [[ -x "$HOME/.fly/bin/flyctl" ]]; then
    unchanged "already installed"
    return
  fi
  spin "Installing flyctl..." sh -c 'curl -fsSL https://fly.io/install.sh | sh -s -- --non-interactive' \
    || bootstrap_error "Failed to install flyctl" \
      "Retry manually: curl -fsSL https://fly.io/install.sh | sh"
}

# bd (beads) is this repo's issue tracker. macOS gets it from the Brewfile;
# Fedora has no dnf or copr package, so use the upstream installer, which
# downloads a checksum-verified release binary into /usr/local/bin when that's
# user-writable, else ~/.local/bin — no sudo either way, like setup-poetry.
setup-beads() {
  is-fedora || return 0
  substep "Checking bd (beads)..."
  if command -v bd &> /dev/null || [[ -x "$HOME/.local/bin/bd" ]]; then
    unchanged "already installed"
    return
  fi
  spin "Installing bd (beads)..." sh -c 'curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash' \
    || bootstrap_error "Failed to install bd" \
      "Retry manually: curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash"
}

setup-beads-applicable() { is-fedora; }

# Rex (superlogical.com/rex) server and CLI. On macOS Rex is a self-contained
# app with its own local server, so there's nothing to script there. On Fedora
# it comes from Superlogical's own signed dnf repo; the repo file is tracked in
# etc/rex/ so its channel is pinned here rather than by the upstream script.
# Its systemd units ship disabled; enabling one is a per-machine choice.
setup-rex() {
  is-fedora || return 0
  substep "Checking Rex..."

  # Fedora's unrelated Perl tool (R)?ex is packaged as "Rex" (capital R) and
  # also owns /usr/bin/rex, so dnf would fail with a bare file conflict.
  if rpm -q Rex &> /dev/null; then
    bootstrap_error "Fedora's unrelated 'Rex' package (the Perl tool (R)?ex) owns /usr/bin/rex" \
      "Remove it, then rerun: sudo dnf remove Rex && juliet-bootstrap --enable=rex"
    return
  fi

  install-system-file "$JULIET_DIR/etc/rex/rex.repo" /etc/yum.repos.d/rex.repo
  local rc=$?
  (( rc == 2 )) && return

  if rpm -q rex &> /dev/null; then
    if (( rc == 1 )); then
      unchanged "already installed"
    else
      # The repo file changed (e.g. a new channel); pick up its build.
      sudo dnf upgrade -y --refresh rex \
        || bootstrap_error "Failed to upgrade rex" "Retry manually: sudo dnf upgrade --refresh rex"
    fi
    return
  fi

  substep "Installing Rex..."
  sudo dnf install -y rex \
    || bootstrap_error "Failed to install rex" "Retry manually: sudo dnf install -y rex"
}

setup-rex-applicable() { is-fedora; }

# Bamboo in Rex.app, from the same Ghostty theme file Ghostty itself uses.
# Rex.app imports a theme through its client.theme.import action, which it only
# accepts with Remote Control on (Settings → Rex Server), so this turns that on
# first: it lets local processes running as you drive Rex.app. Imported themes
# live as JSON in the app's Workspace.customThemes default; finding "bamboo"
# there means it's already imported, and then it's only (re)selected.
REX_BUNDLE_ID="com.superlogical.rex"

rex-app-client() {
  rex client ls --json 2> /dev/null \
    | jq -r 'first(.clients[] | select(.info.kind == "app" and .info.platform == "macos") | .client_id) // empty'
}

rex-has-custom-theme() {
  local plist
  plist=$(mktemp) || return 1
  defaults export "$REX_BUNDLE_ID" "$plist" 2> /dev/null \
    && /usr/libexec/PlistBuddy -c 'Print :Workspace.customThemes' "$plist" 2> /dev/null \
      | grep -q "\"name\":\"$1\""
  local rc=$?
  rm -f "$plist"
  return $rc
}

setup-rex-theme() {
  local theme="$JULIET_DIR/symlinked/config/ghostty/themes/bamboo"
  substep "Checking Rex theme..."

  if [[ "$(defaults read "$REX_BUNDLE_ID" rex.client.remoteControl 2> /dev/null)" != "1" ]]; then
    substep "Turning on Rex Remote Control..."
    defaults write "$REX_BUNDLE_ID" rex.client.remoteControl -bool true
  fi

  # The action goes to the running app; start it in the background if needed.
  local client="" i
  client=$(rex-app-client)
  if [[ -z "$client" ]]; then
    open -gb "$REX_BUNDLE_ID" 2> /dev/null
    for i in {1..20}; do
      client=$(rex-app-client)
      [[ -n "$client" ]] && break
      sleep 0.5
    done
  fi
  if [[ -z "$client" ]]; then
    bootstrap_error "Rex.app isn't running, so its theme can't be set" \
      "Open Rex, then rerun: juliet-bootstrap --enable=rex-theme"
    return
  fi

  if rex-has-custom-theme bamboo; then
    unchanged "bamboo already imported"
  else
    substep "Importing bamboo into Rex..."
    rex -C "$client" "do" client.theme.import path="$theme" || {
      bootstrap_error "Failed to import bamboo into Rex" \
        "Check Remote Control is on in Rex Settings → Rex Server" \
        "Then rerun: juliet-bootstrap --enable=rex-theme"
      return
    }
  fi

  rex -C "$client" "do" client.theme.change name=bamboo \
    || bootstrap_error "Failed to select bamboo in Rex" \
      "Pick it in Rex: Change Theme… → bamboo"
}

setup-rex-theme-applicable() {
  is-macos || return 1
  if ! command -v rex &> /dev/null \
    || [[ -z "$(mdfind "kMDItemCFBundleIdentifier == '$REX_BUNDLE_ID'" 2> /dev/null)" ]]; then
    NA_REASON="Rex.app not installed"
    return 1
  fi
}
