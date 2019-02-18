#!/usr/bin/env bash

system_user=$SYSTEM_USER_NAME
if [[ "$system_user" != "root" && $(grep -c "^$system_user:" /etc/passwd) -eq 0 ]]; then
    echo "Adding system user '$system_user'..."

    adduser -q --disabled-password --no-create-home "$system_user"
	if [ $? -ne 0 ]; then
		echo "Adding system user '$system_user' failed. Aborting..."
		exit 1
	fi
    usermod -a -G www-data "$system_user"
	if [ $? -ne 0 ]; then
		echo "Adding system user '$system_user' to webserver group failed. Aborting..."
		exit 1
	fi
fi
