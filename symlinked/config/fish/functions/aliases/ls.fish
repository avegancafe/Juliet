function ls --wraps eza
    set -l LS_CMD (which ls)

    if type -q eza
        set LS_CMD 'eza'
        set LS_CMD_ARGS '--oneline'
    end

    $LS_CMD $LS_CMD_ARGS $argv
end
