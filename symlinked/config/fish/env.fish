# PATH mutations
set -gx PATH /usr/local/bin $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$GOPATH/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH
set -gx PATH $PATH "$HOME/.foundry/bin"
set -gx PATH "/opt/homebrew/opt/go@1.20/bin" $PATH
set -gx PATH (npm get prefix)/bin $PATH
set -gx PATH "$HOME/.config/Juliet/bin" $PATH
set -gx PATH "$HOME/.config/Juliet/bin/git-hoard/bin" $PATH
set -gx PATH /usr/local/games/bin $PATH
set -gx BUN_INSTALL "$HOME/.bun"
set -gx PATH $BUN_INSTALL/bin $PATH
set -gx MANPAGER 'nvim +Man!'

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

# Language-specific configs
set -Ux PYENV_ROOT $HOME/.pyenv
set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths
set -gx GOPATH "$HOME/go"
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
