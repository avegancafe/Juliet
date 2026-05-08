function clone
    if test -z "$argv[1]"
        error "ERROR: no repo provided"
        return 1
    end

    set -l base_url "git@github.com:"

    gum spin --title "Cloning $argv[1] from github..." -- git clone $base_url$argv[1]

    log Cloned!

    cd (string replace -r "^.+/" "" $argv[1])
end
