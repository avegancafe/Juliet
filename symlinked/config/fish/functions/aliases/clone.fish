function clone
    if test -z "$argv[1]"
        error "ERROR: no repo provided"
        return 1
    end

    set -l provider  (gum choose --height 15 --header "Which source are you cloning from?" github gitlab)
    set -l base_url ""
    if test "$provider" = gitlab
        set base_url "ssh://git@gitlab.com/"
    else if test "$provider" = github
        set base_url "git@github.com:"
    else if test -n "$provider"
        error "ERROR: selected provider $argv[1] not configured"
        return 1
    end

    gum spin --title "Cloning $argv[1] from $provider..." -- git clone $base_url$argv[1]

    log Cloned!

    cd (string replace -r "^.+/" "" $argv[1])
end
