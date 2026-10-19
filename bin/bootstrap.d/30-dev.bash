# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# dev: language toolchains and CLI dev tools.

category dev rlog "🛠️ Installing dev tools..." "Install dev tools?" \
  setup-cargo setup-rust setup-python setup-nodenv setup-node-tools \
  setup-flyctl setup-beads

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
