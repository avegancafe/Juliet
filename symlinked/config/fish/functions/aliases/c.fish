function c --wraps "claude"
    if test "$argv" = "-c"
        set argv $argv continue
    end

    claude $argv
end
