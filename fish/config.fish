eval (/opt/homebrew/bin/brew shellenv)
source ~/.config/fish/env.fish 2>/dev/null

set -gx PATH /usr/local/bin $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$GOPATH/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH
set -gx PATH $PATH "/Users/kyle/.foundry/bin"
set -gx PATH "/opt/homebrew/opt/go@1.16/bin" $PATH 
set -gx PATH (pyenv root)/shims $PATH
set -gx GOPATH "$HOME/go"
set -gx EDITOR vim
set -gx LSCOLORS bxfxcxdxbxegedabagacad
set -gx GPG_TTY (tty)
set -U FZF_LEGACY_KEYBINDINGS 0
set fish_color_command 69f0ad
set -gx FZF_DEFAULT_COMMAND "ag -g ''"
set -gx PG_CONSOLE_COMMAND "pgcli -p 5432 -U kyle -h localhost"
set -gx RELAY_FZF_OPTS "--reverse --height 40%"

ulimit -n 8096

set -gx TERM xterm-256color

source ~/.config/Juliet/fish/_util.fish

function r
    set -l profile

    switch $argv[1]
        case start
            set profile relay
        case sync
            set profile relay-sync
        case '*'
            echo "Usage: r ( start | sync )"
            return
    end

    itermocil $profile --here
end

function watch
  /opt/homebrew/bin/watch -n 5 --color $argv
end

function h
    npx hardhat $argv
end

function update --description "Sync ruby/js project with git"
    argparse --name="update" d/debug -- $argv

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
    git pull -r >$out_stream || begin
        fail
        return
    end

    info "Updating installed gems..."
    bundle install >$out_stream || begin
        fail
        return
    end

    info "Updating installed node modules..."
    yarn install >$out_stream || begin
        fail
        return
    end

    log "Running database migrations..."
    bundle exec rake db:migrate db:test:prepare >$out_stream || begin
        fail
        return
    end

    log "Done!"
end

function current-sha
    git log origin/master -1 --format="short" | sed -E 's/^commit[[:space:]]([^[[:space:]]]*)/\1/' | head -n 1
end

function watch-repo
    git fetch 2>&1 >/dev/null

    set ORIGINAL_COMMIT (current-sha)
    info "Polling for new commits... original commit is $ORIGINAL_COMMIT"

    for x in (seq 20)
        git fetch 2>&1 >/dev/null
        if test "$ORIGINAL_COMMIT" != (current-sha)
            error "WARNING: new commit detected "(current-sha)
        end

        sleep 30
    end
end

function vim
    rm ~/vim.log
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

function sudo
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

function migrate
    set version_number (echo $argv[2] | sed 's/.*db\/data\///' | sed 's/_.*//')
    switch (echo $argv[1])
        case up
            echo "Migrating "(echo $version_number)" "(echo $argv[1])"..."
            bundle exec rake db:migrate:up VERSION=$version_number
        case down
            echo "Migrating "(echo $version_number)" "(echo $argv[1])"..."
            bundle exec rake db:migrate:down VERSION=$version_number
        case "*"
            echo "Usage: migrate [up|down] /path/to/migration_file"
    end
end

function gfg
    set -l fileName (echo $argv[1] | sed 's/dump$/js/')
    stackprof --flamegraph $argv[1] >$fileName
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

function ns
    npm start $argv
end

function @curl
    curl -w "@$HOME/.curl-format.txt" -o /dev/null -s $argv
end

function ls
    set -l LS_CMD (which ls)

    if type -q lsd
        set LS_CMD lsd
    end

    $LS_CMD $argv
end

function _gl --description "print the URL of a file in gitlab"
    argparse --name="_gl" c/current -- $argv

    set -l REMOTE_URL (git remote get-url origin)
    set -l GITLAB_BASE_URL (echo $REMOTE_URL | sed 's/^ssh\:\/\/git\@/https\:\/\//; s/\.git$//; s/\:6767//')

    set -l BRANCH_NAME master

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
    argparse --name="_gl" c/current -- $argv

    _gl $_flag_c $argv | pbcopy
end

function glo --description "open the URL of a file in gitlab"
    argparse --name="_gl" c/current -- $argv

    _gl $_flag_c $argv | xargs open
end

eval (starship init fish)

ssh-add -A 2>/dev/null

# nodenv config
status --is-interactive; and source (nodenv init -|psub)

if status --is-login
    set -gx PATH $HOME/.nodenv/bin $PATH
end

if test -e ~/.config/fish/config__local.fish
    source ~/.config/fish/config__local.fish
end
