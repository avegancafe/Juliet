status --is-interactive; and source (nodenv init -|psub)

if status --is-login
    set -gx PATH $HOME/.nodenv/versions $PATH
end

