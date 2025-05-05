function nv --wraps "neovide"
    if ! command -v neovide 2&> /dev/null
        gum confirm "Neovide not installed. Install?" && brew install --cask neovide
    end

    nohup neovide $argv 2>&1 > /dev/null &

    set -l pid (jobs -l | grep neovide | awk '{print $2}')
    disown $pid
end
