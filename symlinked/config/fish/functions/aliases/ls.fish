function ls
    set -l LS_CMD (which ls)

    if type -q eza
        set LS_CMD eza
    end

    $LS_CMD $argv
end
