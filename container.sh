#!/usr/bin/env bash

command=$1
command_dir="/usr/share/neos-utils"

if [[ ! -f "$command_dir/$command.sh" ]]; then
    echo "Invalid command '$1'."
    exit 1
fi

. $command_dir/$command.sh "${@:2}"