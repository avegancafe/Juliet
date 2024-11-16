function cursor --wraps "cursor"
    set git_root_dir (git rev-parse --show-toplevel)

    set -l dir (pwd)
    while test -d "$dir"
        if test -f "$dir/Pipfile"
            break
        end

        if test "$dir" = "$git_root_dir"
            break
        end

        set dir (dirname "$dir")
    end

    env PYTHONPATH=$dir command cursor
end
