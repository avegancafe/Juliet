function @curl
    curl -w "@$HOME/.curl-format.txt" -o /dev/null -s $argv
end
