#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "System user setup failed: No name given."
	exit 1
fi

system_user=$1

system_user_id=""
if [[ -n "$2" ]]; then
    system_user_id="$2"
fi

system_group="$SERVER_USER_GROUP"
if [[ -n "$3" ]]; then
	system_group="$3"
fi

if [[ "$system_user" != "root" && $(grep -c "^$system_user:" /etc/passwd) -eq 0 ]]; then
    echo "Adding user '$system_user'..."

    if [[ -n "$system_user_id" ]]; then
        adduser -u "$system_user_id" -q --disabled-password --no-create-home "$system_user"
    else
        adduser -q --disabled-password --no-create-home "$system_user"
    fi
	if [ $? -ne 0 ]; then
		echo "Adding user '$system_user' failed. Aborting..."
		exit 1
	fi

#    usermod -a -G $system_group "$system_user"
#	if [ $? -ne 0 ]; then
#		echo "Adding user '$system_user' to group '$system_group' failed. Aborting..."
#		exit 1
#	fi
else
	echo "User '$system_user' already exists."
fi

if [[ " "$(awk -F':' '/'$system_group'/{print $4}' /etc/group | tr , " ")" " == *" $system_user "* ]]; then
	echo "User '$system_user' already added to grop '$system_group'."
else
	echo "Adding user '$system_user' to group '$system_group'..."
    usermod -a -G $system_group "$system_user"
	if [ $? -ne 0 ]; then
		echo "Adding user '$system_user' to group '$system_group' group failed. Aborting..."
		exit 1
	fi
fi

