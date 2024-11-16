function reindex-spotlight
    log 'Enabling spotlight indexing...'
    sudo mdutil -Ea
    log 'Clearing old spotlight cache...'
    sudo mdutil -ai off
    log 'Rebuilding spotlight cache...'
    sudo mdutil -ai on
end
