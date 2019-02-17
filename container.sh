#!/usr/bin/env bash

command_dir="/usr/share/neos-utils"
if [[ -n "$BUILD_PATH_UTILS" ]]; then
    command_dir=$BUILD_PATH_UTILS
fi

command=$1
subcommand=$2

command_path="$command_dir/$command.sh"
command_params=${@:2}
if [[ -d "$command_dir/$command" && -f "$command_dir/$command/$subcommand.sh" ]]; then 
	command_path="$command_dir/$command/$subcommand.sh"
	command_params=${@:3}
elif [[ ! -f "$command_dir/$command.sh" ]]; then
    echo "Invalid command '$command:$subcommand'."
    exit 1
fi

. $command_dir/_init.sh
. $command_path $command_params
