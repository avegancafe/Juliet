function envsource
    for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
        set item (string split -m 1 '=' $line)
        # Blank values are .env.template placeholders (KEY=); exporting them
        # empty would mask a value set elsewhere, so leave the variable alone.
        if test -z "$item[2]"
            continue
        end
        set -gx $item[1] $item[2]
    end
end
