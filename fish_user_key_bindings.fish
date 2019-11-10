function info
  printf (tput setaf 4)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
end

function fish_user_key_bindings
  bind \cl 'echo \e\]1337\;ClearScrollback\x7; clear; commandline -f repaint'
  bind \cc 'commandline ""'
  bind \cb 'fco_preview'
end

fzf_key_bindings

function fco -d "Fuzzy-find and checkout a branch"
  git branch --all | grep -v HEAD | string trim | fzf --height 40% --reverse | read -l result; and git checkout "$result"
end

function fco_preview -d "Fuzzy-find and checkout a branch while previewing incoming commits"
  set branches (
    git --no-pager branch \
      --format="%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)" \
    | sed '/^$/d') || return
  set tags (
    git --no-pager tag | awk '{print "\x1b[35;1mtag\x1b[m\t" $1}') || return
  set raw_target (
    string join \n (string join \n $branches; string join \n $tags) |
    fzf --reverse --height 40% --no-hscroll --no-multi -n 2 --ansi \
      --preview="git --no-pager log -150 --pretty=format:%s '..{2}'" \
      --bind 'ctrl-y:execute-silent(echo {} | awk \'{print $2}\' | pbcopy)+abort') || return

  set target (echo $raw_target | awk '{print $2}')

  echo
  info "Checking out $target..."
  echo

  git checkout $target
  echo
  commandline -f repaint
end
