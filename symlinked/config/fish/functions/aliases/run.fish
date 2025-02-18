function run
    argparse --name="run" c/current a/args= -- $argv
    set -l workflow_name $argv
    set -l ref_arg ""

    if test -n "$_flag_c"
        set ref_arg "--ref (current-branch)"
    end

    rlog "Running `gh workflow run $ref_arg $_flag_a $workflow_name`..."
    eval "gh workflow run $ref_arg $workflow_name $_flag_a "

    gum spin sleep 15 --title "Waiting for workflow to start... (~15s)" -- $workflow
    set -l run_id (gh run list --workflow=$workflow_name | grep -o 'in_progress.*workflow_dispatch[[:space:]]*[0-9]\{10,\}' | awk -F'workflow_dispatch[[:space:]]*' '{print $2}' | awk '{print substr($1, 1, 11); exit}')

    if test -z "$run_id"
        error "No run ID found— please select a run"
        echo "Debug output:"
        echo (gh run list --workflow=$workflow)
        gh run watch
        return 0
    end

    log "Workflow run found! Watching run $run_id..."
    sleep 2

    gh run watch $run_id
end

