function fish_user_key_bindings
    bind \cl 'echo \e\]1337\;ClearScrollback\x7; clear; commandline -f repaint'
    bind \cc 'commandline ""'
    bind \cb fco_preview
    bind \cn 'git rebase --continue'
end

source ~/.config/fish/functions/fzf_key_bindings.fish
fzf_key_bindings

function fco -d "Fuzzy-find and checkout a branch"
    git branch --all | grep -v HEAD | string trim | fzf --height 40% --reverse | read -l result; and git checkout "$result"
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
      --bind 'ctrl-y:execute-silent(echo {} | awk \'{print $2}\' | pbcopy)+abort' \
      --bind 'ctrl-x:execute-silent(echo {} | awk \'{print $2}\' | xargs git branch -D)+abort' \
  ) || return

    set target (echo $raw_target | awk '{print $2}')

    echo
    log "Checking out $target..."

    git checkout $target

    log "Done!"
    echo
    echo
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

    set -l process_name (ps -o command= -p $pid)

    log "Killing '$process_name'..."
    echo $pid | xargs kill -9
end
