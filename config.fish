source ~/.config/fish/env.fish 2> /dev/null

set -gx PATH "/usr/local/bin" $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/.config/yarn/global/node_modules/bin" $PATH
set -gx EDITOR "vim"
set -gx PATH $PATH "/usr/local/opt/postgresql@11/bin"
set -gx LSCOLORS "bxfxcxdxbxegedabagacad"
set -gx USE_PSEUDOLOCALIZATION "false"
set -gx GPG_TTY (tty)
set -U FZF_LEGACY_KEYBINDINGS 0
set PATH $HOME/.rbenv/shims $PATH
set fish_color_command 69f0ad
set -gx FZF_DEFAULT_COMMAND "ag -g ''"

set -gx TERM "xterm-256color"

function info
  printf (tput setaf 2)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
end

function log
  printf (tput setaf 4)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
end

function error
  printf (tput setaf 1)"==>"(tput sgr0)(tput bold)" %s"(tput sgr0)"\n" $argv[1]
end

function padlines
  echo
  $argv
  echo
end

function indent
  set -l output ($argv)
  set -l tmp_status $status
  string join \n $output | sed 's/^/  /'
  return $tmp_status
end


function update --description "Sync ruby/js project with git"
  argparse --name="update" 'd/debug' -- $argv

  set -l out_stream
  if test -n "$_flag_d"
    set out_stream /dev/tty
  else
    set out_stream /dev/null
  end

  function fail
    error "Fail :("
  end

  log "Pulling from git..."
  git pull -r > $out_stream || begin;
    fail
    return
  end

  info "Updating installed gems..."
  bundle install > $out_stream || begin;
    fail
    return
  end

  info "Updating installed node modules..."
  yarn install > $out_stream || begin;
    fail
    return
  end

  log "Running database migrations..."
  bundle exec rake db:migrate > $out_stream || begin;
    fail
    return
  end

  log "Done!"
end

function vim
  nvim $argv
end

function fish_greeting
  fortune
end

function gut
  git $argv
end

function ch
  yarn lint && yarn test --runInBand && bundle exec rubocop && yarn lint:ruby && bundle exec rspec && echo -e "\033[41m\033[37m\nGREAT SUCCESS\n\033[0m"
end

function rails
  bundle exec rails $argv
end

function rspec
  bundle exec rspec $argv
end

function dc
  docker-compose $argv
end

function rake
  bundle exec rake $argv
end

function s
  git status -s
end

function ss
  git status
end

function kill_rspec
  kill (ps aux | grep '[r]spec' | awk '{print $2}')
end

function alert
  terminal-notifier -title "Command finished" -activate com.googlecode.iterm
end

function resource
  source ~/.config/fish/config.fish
end

function sudo
  if test "$argv" = !!
    eval command sudo $history[1]
  else
    command sudo $argv
  end
end

function l
  ls -pG1 $argv
end

function be
  bundle exec $argv
end

function migrate
  set version_number (echo $argv[2] | sed 's/.*db\/data\///' | sed 's/_.*//')
  switch (echo $argv[1])
  case "up"
    echo "Migrating "(echo $version_number)" "(echo $argv[1])"..."
    bundle exec rake db:migrate:up VERSION=$version_number
  case "down"
    echo "Migrating "(echo $version_number)" "(echo $argv[1])"..."
    bundle exec rake db:migrate:down VERSION=$version_number
  case "*"
    echo "Usage: migrate [up|down] /path/to/migration_file"
  end
end

function gb
  git branch | sed 's/[\* ]//g' | fzf | read -l selected_branch; and git co $selected_branch
end

function gfg
  set -l fileName (echo $argv[1] | sed 's/dump$/js/')
  stackprof --flamegraph $argv[1] > $fileName
  set -l url (stackprof --flamegraph-viewer $fileName | sed 's/open //')
  echo "Opening $url"
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --app=$url
end

function ga
  git commit -C @ --amend $argv
end

function gl
  git log -10 $argv
end

function rs
  bundle exec rails s
end

function ys
  yarn start $argv
end

function @curl
  curl -w "@$HOME/.curl-format.txt" -o /dev/null -s $argv
end

rbenv rehash >/dev/null ^&1
eval (starship init fish)

ssh-add -A 2> /dev/null
