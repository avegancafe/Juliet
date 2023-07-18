eval (/opt/homebrew/bin/brew shellenv)
source ~/.config/fish/env.fish 2>/dev/null
set -gx PATH /usr/local/bin $PATH
set -gx PATH "$HOME/.local/bin" $PATH
set -gx PATH "$GOPATH/bin" $PATH
set -gx PATH "$HOME/.cargo/bin" $PATH
set -gx PATH $PATH "$HOME/.foundry/bin"
set -gx PATH "/opt/homebrew/opt/go@1.18/bin" $PATH
set -gx PATH (pyenv root)/shims $PATH
set -gx GOPATH "$HOME/go"
set -gx EDITOR vim
set -gx LSCOLORS bxfxcxdxbxegedabagacad
set -gx GPG_TTY (tty)
set -U FZF_LEGACY_KEYBINDINGS 0
set fish_color_command 69f0ad
set -gx PG_CONSOLE_COMMAND "pgcli -p 5432 -U $(whoami) -h localhost"
set -gx RELAY_FZF_OPTS "--reverse --height 40%"
set -gx TERM xterm-256color
set -gx PATH (npm get prefix)/bin $PATH
set -gx PATH "$HOME/.config/Juliet/bin" $PATH
set -gx PATH "$HOME/.config/Juliet/bin/git-hoard/bin" $PATH
set -gx DENO_INSTALL "$HOME/.deno"
set -gx PATH "$DENO_INSTALL/bin" $PATH
set -gx PATH /usr/local/games/bin $PATH

set -gx FOUNDRY_FMT_LINE_LENGTH 100
set -gx FOUNDRY_FMT_TAB_WIDTH 2
set -gx FOUNDRY_FMT_BRACKET_SPACING true
set -gx FOUNDRY_FMT_QUOTE_STYLE single

set -gx TERM xterm-256color

source ~/.config/Juliet/fish/_util.fish

function current-branch
    git branch | grep "\*" | sed -e "s/^\*[[:space:]]//" | tr -d '\n'
end

function default-branch
    git branch | grep -m 1 -Eo '\\smain|\\smaster'
end

function update-kitty
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
end

function envsource
    for line in (cat $argv | grep -v '^#' | grep -v '^\s*$')
        set item (string split -m 1 '=' $line)
        set -gx $item[1] $item[2]
        echo "Exported key $item[1]"
    end
end

function b
    rlog "Checking package with name $argv[1]..."
    brew info $argv[1]

    if test $status -eq 0
        gum confirm "Install?" && brew install $argv[1]
    else
        set --local package (brew info $argv[1] 2>&1 | grep -Eo "Did you mean ([[:alpha:]-]*)\?" | sed -e "s/Did you mean //g" -e "s/?//g")

        gum confirm "Install $package instead?"

        if test $status -eq 0
            rlog "Installing $package..."
            brew install $package
        else
            error Exiting
        end
    end
end

function p
    pnpm $argv
end

function refsl
    log 'Enabling spotlight indexing...'
    sudo mdutil -Ea
    log 'Clearing old spotlight cache...'
    sudo mdutil -ai off
    log 'Rebuilding spotlight cache...'
    sudo mdutil -ai on
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

    rlog "Pulling from git..."
    git pull -r >$out_stream || begin
        fail
        return
    end

    rlog "Updating installed gems..."
    bundle install >$out_stream || begin
        fail
        return
    end

    rlog "Updating installed node modules..."
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
    rlog "Polling for new commits... original commit is $ORIGINAL_COMMIT"

    for x in (seq 20)
        git fetch 2>&1 >/dev/null
        if test "$ORIGINAL_COMMIT" != (current-sha)
            error "WARNING: new commit detected "(current-sha)
        end

        sleep 30
    end
end

function vim
    argparse --name="debug" d/debug -- $argv

    if test -n "$_flag_d"
        rm ~/vim.log
        nvim --startuptime ~/vim.log $argv
    else
        nvim $argv
    end
end

function fish_greeting
end

function g
    git $argv
end

function gut
    git $argv
end

function dc
    docker compose $argv
end

function st
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

    if type -q exa
        set LS_CMD exa
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

function changed_files
    echo (git status --short | sed "s/[[:alnum:]?]\{1,2\}[[:space:]]\(.*\)/\1/g")
end

function rtb
    pkill "Touch Bar agent"
    killall ControlStrip
end

function note
    echo "date: $(date)" >>$HOME/notes.txt
    echo "$argv" >>$HOME/notes.txt
    echo "" >>$HOME/notes.txt
end

eval (starship init fish)

ssh-add -A 2>/dev/null

# nodenv config
status --is-interactive; and source (nodenv init -|psub)

if status --is-login
    set -gx PATH $HOME/.nodenv/versions $PATH
end

if test -e ~/.config/fish/config__local.fish
    source ~/.config/fish/config__local.fish
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# glow
glow completion fish | source
