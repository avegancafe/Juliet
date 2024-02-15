#! /bin/sh

eval `/opt/homebrew/bin/brew shellenv`

terminal-notifier -message "Updating kitty..." -title Juliet
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

if [[ $? == 0 ]]; then
	terminal-notifier -message "Kitty has been successfully updated :)" -title Juliet
else
	terminal-notifier -message "Kitty update has failed :(" -title Juliet
fi
