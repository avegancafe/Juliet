# PATH mutations
# GOPATH is set here rather than with the other language configs below because
# the PATH line for $GOPATH/bin needs it. Set later, it expanded to empty on a
# fresh machine's first shell — $GOPATH/bin became "/bin" and go-installed
# binaries (e.g. claude-statusline) stayed off PATH until a later shell
# inherited the exported var.
set -gx GOPATH "$HOME/go"

set -gx PATH /usr/local/bin $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$GOPATH/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH
set -gx PATH $PATH "$HOME/.foundry/bin"
set -gx PATH "/opt/homebrew/opt/go@1.20/bin" $PATH
set -gx PATH (npm config get prefix)/bin $PATH
set -gx PATH "$HOME/.config/Juliet/bin" $PATH
set -gx PATH "$HOME/.config/Juliet/bin/git-hoard/bin" $PATH
set -gx PATH /usr/local/games/bin $PATH
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PATH $BUN_INSTALL/bin $PATH

# General system configs
set -gx EDITOR nvim
set fish_color_command 69f0ad
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx TERM xterm-256color
set -l RESET_CODE (tput sgr0)
set -gx LESS_TERMCAP_md (tput setaf 2)
set -gx LESS_TERMCAP_me $RESET_CODE
set -gx LESS_TERMCAP_us (tput setaf 4)
set -gx LESS_TERMCAP_ue $RESET_CODE
set -gx LESS_TERMCAP_so (tput setaf 1)
set -gx LESS_TERMCAP_se $RESET_CODE
set -gx MANPAGER 'nvim +Man!'

# Language-specific configs
set -Ux PYENV_ROOT $HOME/.pyenv
set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
# node-gyp picks the default `python3` (broken Homebrew python@3.14 — pyexpat fails
# to load), so point native-addon builds at a working interpreter instead.
set -gx PYTHON /opt/homebrew/bin/python3.11
# GOPATH is set in the PATH block above (it's a dependency of that block).
set -gx PIPENV_SHELL_FANCY 1


# Application-specific configs
set -gx GPG_TTY (tty)
set -U FZF_LEGACY_KEYBINDINGS 0
set -gx PG_CONSOLE_COMMAND "pgcli -p 5432 -U $(whoami) -h localhost"
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/rc"
set -gx FOUNDRY_FMT_LINE_LENGTH 100
set -gx FOUNDRY_FMT_TAB_WIDTH 2
set -gx FOUNDRY_FMT_BRACKET_SPACING true
set -gx FOUNDRY_FMT_QUOTE_STYLE single
set -gx NEOVIDE_TITLE_HIDDEN 1
set -gx NEOVIDE_FRAME buttonless

# Juliet-local opencode overrides, layered by opencode BETWEEN the global
# ~/.config/opencode/opencode.json (symlinked by dev-env's `j2 bootstrap` to
# the org config: pinned j2 plugins, team MCP servers, permission baseline,
# LSPs, default_agent — org-managed, read-only) and per-project configs.
# Two rules for Juliet's file:
#   1. Only Juliet-owned opencode.json keys — do NOT add plugin/mcp/lsp keys,
#      that forks the dev-env org config.
#   2. NEVER add the deprecated theme/tui/keybinds keys — opencode rewrites
#      any config file containing them in place (verified on 1.18.0), which
#      would dirty this repo. Theme lives in the seeded tui.json instead
#      (see setup-opencode in bin/juliet-bootstrap).
# Fallback semantics: opencode has ONE OPENCODE_CONFIG slot, so a machine may
# claim it earlier (e.g. conf.d/00-*.fish pointing at a personal local.json
# with `model`/`shell`); Juliet's layer applies where unclaimed.
set -q OPENCODE_CONFIG; or set -gx OPENCODE_CONFIG "$HOME/.config/Juliet/opencode/config.json"
