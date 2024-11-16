function logs
    set -l service (echo '["j2-network-manger", "network-intel-dashboard", "network-intel-dashboard-qa", "network-intel-dashboard-staging"]' | jq -r .[] | fzf --reverse --height 40% --prompt "Which service logs would you like to see? ")

    gcloud app logs tail --service $service
end

