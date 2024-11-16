function current-sha
    git log origin/main -1 --format="short" | sed -E 's/^commit[[:space:]]([^[[:space:]]]*)/\1/' | head -n 1
end
