# OS-specific SSH agent/keychain setup
switch (uname)
    case Darwin
        source (dirname (status filename))/ssh-macos.fish
end

