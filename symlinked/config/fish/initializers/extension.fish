# Fish config from your Juliet extensions, in JULIET_EXTENSION order (see
# EXTENSIONS.md). juliet-bootstrap writes the order to .order.
if test -f ~/.config/juliet-extensions/.order
    for name in (cat ~/.config/juliet-extensions/.order)
        if test -e ~/.config/juliet-extensions/$name/fish/config.fish
            source ~/.config/juliet-extensions/$name/fish/config.fish
        end
    end
end
