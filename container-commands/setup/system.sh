#!/usr/bin/env bash

neos-utils setup system-user $SYSTEM_USER_NAME
if [ $? -ne 0 ]; then
	echo "Adding system user '$SYSTEM_USER_NAME' failed. Aborting..."
	exit 1
fi

neos-utils setup system-user $SERVER_USER_NAME
if [ $? -ne 0 ]; then
	echo "Adding server user '$SERVER_USER_NAME' failed. Aborting..."
	exit 1
fi
