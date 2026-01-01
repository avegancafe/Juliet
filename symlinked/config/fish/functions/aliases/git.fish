function ga
    git commit -C @ --amend $argv
end

function gl
    git log -10 $argv
end

function _gh --description "print the URL of a file in github"
    argparse --name="_gh" c/current -- $argv

    set -l REMOTE_URL (git remote get-url origin)
    set -l GITHUB_BASE_URL (echo $REMOTE_URL | sed -e 's/^ssh\:\/\/git\@//' -e 's/^git\@//' -e 's/^https\:\/\///' -e 's/\.git$//' -e 's/\:6767//' -e 's/.com\:/.com\//')

    set -l BRANCH_NAME main

    if test $_flag_c
        set BRANCH_NAME (git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    end

    set -l CURRENT_PATH (git rev-parse --show-prefix)

    set -l FILE_PATH $argv[1]

    if test -n $CURRENT_PATH
        set FILE_PATH "$CURRENT_PATH$FILE_PATH"
    end

    if test -z $argv[1]
        echo $GITHUB_BASE_URL
    else
        echo "https://$GITHUB_BASE_URL/blob/$BRANCH_NAME/$FILE_PATH"
    end
end

function glc --description "copy the URL of a file in github"
    argparse --name="_gh" c/current -- $argv

    _gh $_flag_c $argv | pbcopy
end

function gho --description "open the URL of a file in github"
    argparse --name="_gh" c/current -- $argv

    _gh $_flag_c $argv | xargs open
end

function changed_files
    echo (git status --short | sed "s/[[:alnum:]?]\{1,2\}[[:space:]]\(.*\)/\1/g")
end

function commit
    argparse --name="commit" s/short r/retry -- $argv
    set -l message $argv

    if test -n "$_flag_r"
        set -l commit_message_file .git/COMMIT_EDITMSG

        if test -f $commit_message_file
            set message (cat $commit_message_file)
            log "Committing and reusing message '$message'..."
            git commit --message "$message"
            return 0
        else
            error "No previous commit message found— exiting..."
            return 1
        end
    end

    if test -z "$message"
        error "Commit message not provided— exiting..."
        printf '\nUsage:\n$ commit [-s] <message>\n\n'
        return 1
    end

    if test -n "$_flag_s"
        set -l initials $(test -n $GIT_INITIALS && echo $GIT_INITIALS || echo 'KH')

        git commit --message "[$initials] $message"
        log "Committing with message '[$initials] $message'..."
        return 0
    end

    echo

    set -l commit_type (gum choose --height 5 --header.foreground "#8fb573" --header "What type of commit is this?" feat fix chore tmp)

    if test -z "$commit_type"
        error "No commit type selected— exiting..."
        return 1
    end

    log "Commit type: $commit_type"

    set -l scope (gum input --header.foreground "#8fb573" --header "What is the scope of this commit?")

    set -l scope_status $status

    if test $scope_status -ne 0
        error "No scope selected— exiting..."
        return 1
    end

    set scope (string replace -r '^.' (string upper (string sub -l 1 -- $scope)) -- $scope)

    if test -n "$scope"
        log "Scope: $scope"
        log "Committing with message '$commit_type($scope): $message'..."
        git commit --message "$commit_type($scope): $message"
    else
        log "Committing with message '$commit_type: $message'..."
        git commit --message "$commit_type: $message"
    end

    if test $status -ne 0
        error "Commit failed. Saving messaging and exiting..."
        if test -n "$scope"
            echo "$commit_type($scope): $message" > .git/COMMIT_EDITMSG
        else
            echo "$commit_type: $message" > .git/COMMIT_EDITMSG
        end
        return 1
    end
end

function gm
    git rebase -i main
end

