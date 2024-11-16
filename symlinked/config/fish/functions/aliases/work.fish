function work
    if ! test -e ~/.workspaces && ! test -e ~/.workspaces__local
        echo "Looks like you don't have workspaces set up. To use this function, create a
file called ~/.workspaces or ~/.workspaces__local that looks like the following:

```
@workspace ~/workspace
@dir ~/.config/nvim
```
where @workspace denotes a directory in which many other directories reside, 
and @dir denotes a specific directory that should be listed when running this
command"
        return 1
    end
    set -l all_workspaces ""

    if test -e ~/.workspaces
        set all_workspaces "$(cat ~/.workspaces)"
    end

    if test -e ~/.workspaces__local
        set all_workspaces "$all_workspaces
$(cat ~/.workspaces__local)"
    end

    set -l dirs (echo "$all_workspaces" | grep @dir | awk '{print $2}')
    set -l workspaces (echo "$all_workspaces" | grep @workspace | awk '{print $2}')

    set -l fin ""

    if test "$dirs" != ""
        set fin "$dirs"
    end

    for dir in (string split ' ' "$workspaces");
        if test -n "$dir"
            set fin "$fin"\n"$(bash -c "ls -1d $dir/*/")"
        end
    end


    set -l selection (echo "$fin" | grep -v '^$' | gum filter --limit 1 --height 10 --placeholder "Which directory would you like to cd to?")

    if test -z "$selection"
        error Exiting...
        return 1
    end

    debuglog "cd-ing to $selection..."
    cd $selection
end
