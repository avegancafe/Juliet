fzf --fish | source

function fish_user_key_bindings
    bind \cl 'echo \e\]1337\;ClearScrollback\x7; clear; commandline -f repaint'
    bind \cc 'commandline ""'
    bind \cb fco_preview
    bind \cn 'git rebase --continue'
    fzf --fish | source
end

function fco -d "Fuzzy-find and checkout a branch"
    git branch --all | grep -v HEAD | string trim | fzf --height 40% --reverse | read -l result; and git checkout "$result"
end

function fjobs -d "Kill background jobs"
    jobs | tail -n +1 | fzf --height 40% --reverse \
        --bind 'ctrl-y:execute-silent(echo {} | cut -c2- | sed -E \'s/([[:digit:]]+).*/\1/g\' | tr \'\n\' \' \' | xargs kill -9)+abort' \
        --bind 'ctrl-r:reload(eval "$FZF_DEFAULT_COMMAND")' \
        --header='ctrl-y: kill process' | read -l result; and fg $(echo $result | awk '{print $2}')

    commandline -f repaint
end

function fco_preview -d "Fuzzy-find and checkout a branch while previewing incoming commits"
    set branches (
    git --no-pager branch \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
      | sed '/^$/d'
    ) || return
    set tags (git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
    set raw_target (
        string join \n (string join \n $branches; string join \n $tags) |
            fzf --reverse --height 40% --no-hscroll --no-multi -n 2 --ansi \
              --preview="git --no-pager log -150 --pretty=format:%s '..{2}'" \
              --header='ctrl-y: copy name — ctrl-x: delete branch' \
              --bind 'ctrl-y:execute-silent(echo {} | awk \'{print $2}\' | xargs printf "%s" | pbcopy)+abort' \
              --bind 'ctrl-x:execute-silent(echo {} | awk \'{print $2}\' | xargs git branch -D)+abort' \
    )

    set fzf_status $status

    if test $fzf_status -ne 0
        error "Operation cancelled-- Exiting...\n"
        echo
        commandline -f repaint
        return
    end

    set target (echo $raw_target | awk '{print $2}')

    log "Checking out $target..."

    git checkout $target
    echo ""

    commandline -f repaint
end

function fkill -d "Fuzzy-find process and kill it"
    set -l fzf_args --reverse --height 40% --no-hscroll -n 8 --ansi --multi
    set -l pid

    if test (id -u) -eq 0
        set pid (ps -f -u $UID | sed 1d | fzf $fzf_args | awk '{print $2}')
    else
        set pid (ps -ef | sed 1d | fzf $fzf_args | awk '{print $2}')
    end

    echo $pid
    if test "$pid" = ''
        return
    end

    set -l process_name (ps -o command= -p $pid)

    log "Killing '$process_name'..."
    echo $pid | xargs kill -9
end
