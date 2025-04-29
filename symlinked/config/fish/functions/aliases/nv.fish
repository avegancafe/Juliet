function nv --wraps "neovide"
    if ! command -v neovide 2&> /dev/null
        gum confirm "Neovide not installed. Install?" && brew install --cask neovide
    end

    neovide $argv &
end
