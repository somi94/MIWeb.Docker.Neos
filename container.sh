#!/usr/bin/env bash

command_dir="/usr/share/neos-utils"
if[[ -n "$BUILD_PATH_UTILS" ]]; then
    command_dir=$BUILD_PATH_UTILS
fi

command=$1

if [[ ! -f "$command_dir/$command.sh" ]]; then
    echo "Invalid command '$1'."
    exit 1
fi

. $command_dir/_init.sh
. $command_dir/$command.sh "${@:2}"
