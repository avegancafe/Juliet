# shellcheck shell=bash disable=SC2034  # globals are shared across modules
# Sourced by bin/juliet-bootstrap (never run directly).
# shell: fish as the login shell, fzf, tmux plugins.

category shell log "🐚 Configuring shell..." "Configure shell?" \
  setup-fish setup-fzf setup-tmux-plugins

# The account's login shell (what chsh changes), not $SHELL — $SHELL is
# inherited from whatever launched bootstrap and can differ.
account-login-shell() {
  if is-macos; then
    dscl . -read "$HOME" UserShell 2>/dev/null | awk '{print $2}'
  else
    getent passwd "$(id -un)" | cut -d: -f7
  fi
}

setup-fzf() {
  substep "Checking fzf..."
  if ! command -v fzf &> /dev/null; then
    rlog "Installing fzf..."
    /opt/homebrew/opt/fzf/install
  fi
  unchanged "already installed"
}

setup-tmux-plugins() {
  # tpm (tmux plugin manager) bootstraps the plugins declared in the tracked
  # .tmux.conf; nothing installs it besides this clone.
  substep "Checking tpm..."
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    spin "Installing tpm..." git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" \
      || bootstrap_error "Failed to clone tpm" \
        "Retry manually: git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
  fi
  unchanged "already installed"
}

setup-fish() {
  mkdir -p ~/.config/fish

  FISH_PATH="$(command -v fish)"
  if [[ -z "$FISH_PATH" ]]; then
    warn "fish not found, skipping fish setup"
    return
  fi
  substep "Setting up fish..."

  if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
    substep "Adding $FISH_PATH to /etc/shells..."
    sudo bash -c "echo '$FISH_PATH' >> /etc/shells"
  fi

  local login_shell
  login_shell="$(account-login-shell)"
  if [[ "${login_shell:-$SHELL}" != "$FISH_PATH" ]]; then
    substep "Setting fish to default shell..."
    _step_close # chsh prompts for a password; keep it off the step line
    chsh -s "$FISH_PATH" "$(whoami)"
  else
    skip "already the default shell"
  fi
}
