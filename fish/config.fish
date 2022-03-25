eval (/opt/homebrew/bin/brew shellenv)
source ~/.config/fish/env.fish 2> /dev/null

set -gx NeovideMultiGrid "true"
set -gx PATH "/usr/local/bin" $PATH set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$HOME/.config/yarn/global/node_modules/.bin" $PATH
set -gx GOPATH "$HOME/go"
set -gx PATH "$GOPATH/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH
set -gx EDITOR "vim"
set -gx PATH $PATH "/usr/local/opt/postgresql@12/bin"
set -gx LSCOLORS "bxfxcxdxbxegedabagacad"
set -gx USE_PSEUDOLOCALIZATION "false"
set -gx GPG_TTY (tty)
set -U FZF_LEGACY_KEYBINDINGS 0
set fish_color_command 69f0ad
set -gx FZF_DEFAULT_COMMAND "ag -g ''"
set -gx RUBY_CFLAGS "-DUSE_FFI_CLOSURE_ALLOC"
set -gx DYLD_LIBRARY_PATH "/opt/homebrew/lib"
set -gx PG_CONSOLE_COMMAND "pgcli -p 5432 -U kyle -h localhost"
set -gx RELAY_FZF_OPTS "--reverse --height 40%"

ulimit -n 8096

set -gx TERM "xterm-256color"

source ~/.config/Juliet/fish/_util.fish

function h
  npx hardhat $argv
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

  info "Pulling from git..."
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
  bundle exec rake db:migrate db:test:prepare > $out_stream || begin;
    fail
    return
  end

  log "Done!"
end

function current-truva-sha
  git log origin/master -1 --format="short" | sed -E 's/^commit[[:space:]]([^[[:space:]]]*)/\1/' | head -n 1
end

function watch-truva
  git fetch 2>&1 > /dev/null

  set ORIGINAL_COMMIT (current-truva-sha)
  info "Polling viewthespace/truva for new commits... original commit is $ORIGINAL_COMMIT"

  for x in (seq 20)
    git fetch 2>&1 > /dev/null
    if test "$ORIGINAL_COMMIT" != (current-truva-sha)
      terminal-notifier -message 'WARNING: new commit detected'
      error "WARNING: new commit detected "(current-truva-sha)
    end

    sleep 30
  end
end

function vim
  nvim --startuptime ~/vim.log $argv 
end

function fish_greeting
  fortune
end

function gut
  git $argv
end

function dc
  docker compose $argv
end

function s
  git status -s
end

function alert
  terminal-notifier -title "Command finished" -activate com.googlecode.iterm
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

function ys
  yarn start $argv
end

function @curl
  curl -w "@$HOME/.curl-format.txt" -o /dev/null -s $argv
end

function ls
  set -l LS_CMD (which ls)

  if type -q "lsd"
    set LS_CMD "lsd"
  end

  $LS_CMD $argv
end

function _gl --description "print the URL of a file in gitlab"
  argparse --name="_gl" 'c/current' -- $argv

  set -l REMOTE_URL (git remote get-url origin)
  set -l GITLAB_BASE_URL (echo $REMOTE_URL | sed 's/^ssh\:\/\/git\@/https\:\/\//; s/\.git$//; s/\:6767//')

  set -l BRANCH_NAME "master"

  if test $_flag_c
    set BRANCH_NAME (git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  end

  set -l CURRENT_PATH (git rev-parse --show-prefix)

  set -l FILE_PATH $argv[1]

  if test -n $CURRENT_PATH
    set FILE_PATH "$CURRENT_PATH$FILE_PATH"
  end

  if test -z $argv[1]
    echo $GITLAB_BASE_URL
  else
    echo "$GITLAB_BASE_URL/-/blob/$BRANCH_NAME/$FILE_PATH"
  end
end

function glc --description "copy the URL of a file in gitlab"
  argparse --name="_gl" 'c/current' -- $argv

  _gl $_flag_c $argv | pbcopy
end

function glo --description "open the URL of a file in gitlab"
  argparse --name="_gl" 'c/current' -- $argv

  _gl $_flag_c $argv | xargs open
end

eval (starship init fish)

ssh-add -A 2> /dev/null

# opam configuration
source /Users/kyle/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true

# nodenv config
status --is-interactive; and source (nodenv init -|psub)

if status --is-login
  set -gx PATH $HOME/.nodenv/bin $PATH
end

if test -e ~/.config/fish/config__local.fish
  source ~/.config/fish/config__local.fish
end
