eval (/opt/homebrew/bin/brew shellenv)

set script_dir (dirname (status --current-filename))
source $script_dir/env.fish 2>/dev/null
source $script_dir/_util.fish

function sourcedir --description "Source all files in a directory"
    for file in $argv[1]/*
        if test -f $file
            source $file
        else
            error "I didn't think you could get here, skipping sourcing $file..."
        end
    end
end

sourcedir $script_dir/initializers
sourcedir $script_dir/functions/aliases


# welcome, here is your fortune for this shell
if command -v fortune 2&> /dev/null && test -n "$FORTUNE" && status --is-interactive
    fortune
end

# J2 Initializers
sourcedir ~/workspace/dev-env/initializers/fish
