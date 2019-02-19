#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "System user setup failed: No name given."
	exit 1
fi

system_user=$1

system_group="$SERVER_USER_GROUP"
if [[ -n "$2" ]]; then
	system_group="$2"
fi

if [[ "$system_user" != "root" && $(grep -c "^$system_user:" /etc/passwd) -eq 0 ]]; then
    echo "Adding user '$system_user'..."

    adduser -q --disabled-password --no-create-home "$system_user"
	if [ $? -ne 0 ]; then
		echo "Adding user '$system_user' failed. Aborting..."
		exit 1
	fi
    usermod -a -G $system_group "$system_user"
	if [ $? -ne 0 ]; then
		echo "Adding user '$system_user' to webserver group failed. Aborting..."
		exit 1
	fi
else
	echo "User '$system_user' already exists."
fi
