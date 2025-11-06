if test -f /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -f /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

set script_dir (dirname (status --current-filename))
source $script_dir/env.fish 2>/dev/null
source $script_dir/_util.fish

function sourcedir --description "Source all files in a directory"
    for file in $argv[1]/*
        if string match -r '\.fish$' $file 2>&1 > /dev/null
            source $file
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
for file in ~/workspace/dev-env/initializers/fish/*; source $file; end
