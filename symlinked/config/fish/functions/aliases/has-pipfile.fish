function has_pipfile
    set -l dir (pwd)
    while test -d "$dir"
        if test -f "$dir/Pipfile"
            return 0
        end
        if test "$dir" = "/"
            break
        end
        set dir (dirname "$dir")
    end
    return 1
end
