#!/usr/bin/env bash

while true; do
    if [[ -n "$RUNNER_COMMAND" ]]; then
        echo "Running ..."
        $RUNNER_COMMAND
    fi
    
    echo "Sleeping for 30s..."
    sleep 30
done
