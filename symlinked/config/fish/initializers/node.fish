# On Linux nodenv is git-cloned to ~/.nodenv (no package), so its bin dir
# isn't on PATH like the brew install on macOS.
if test -d $HOME/.nodenv/bin
    set -gx PATH $HOME/.nodenv/bin $PATH
end

status --is-interactive; and source (nodenv init -|psub)

if status --is-login
    set -gx PATH $HOME/.nodenv/shims $PATH
end

