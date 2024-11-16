function default-branch
    git branch | grep -m 1 -Eo '\\smain|\\smaster'
end
