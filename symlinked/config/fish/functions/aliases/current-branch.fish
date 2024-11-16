function current-branch
    git rev-parse --abbrev-ref HEAD | tr -d '\n'
end

function cb
    current-branch | pbcopy
    log Copied (current-branch)
end
