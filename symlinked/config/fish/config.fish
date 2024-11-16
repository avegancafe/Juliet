eval (/opt/homebrew/bin/brew shellenv)

set script_dir (dirname (status --current-filename))
source $script_dir/env.fish 2>/dev/null
source $script_dir/_util.fish
source $script_dir/initializers/init.fish
source ~/.config/fish/functions/aliases/init.fish


# welcome, here is your fortune for this shell
if command -v fortune 2&> /dev/null && test -n "$FORTUNE" && status --is-interactive
    fortune
end

# J2 Initializers
for file in ~/workspace/dev-env/initializers/fish/*; source $file; end
