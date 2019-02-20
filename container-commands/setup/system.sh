#!/usr/bin/env bash

neos-utils setup system-user $SYSTEM_USER_NAME $SYSTEM_USER_ID
if [ $? -ne 0 ]; then
	echo "Adding system user '$SYSTEM_USER_NAME' (id: '$SYSTEM_USER_ID') failed. Aborting..."
    exit 1
fi

neos-utils setup system-user $SERVER_USER_NAME $SERVER_USER_ID
if [ $? -ne 0 ]; then
    echo "Adding server user '$SERVER_USER_NAME' (id: '$SERVER_USER_ID') failed. Aborting..."
    exit 1
fi

if [[ ! -f "$BUILD_PATH_KEYS/id_rsa_deploy" ]]; then
    echo "No deployment key given, generating it..."
    ssh-keygen -q -t rsa -N '' -f "$BUILD_PATH_KEYS/id_rsa_deploy"
fi
echo "Setting up deployment key..."
mkdir "/root/.ssh"
chmod ga-rwx "/root/.ssh"
chmod u+rw "/root/.ssh"
cp "$BUILD_PATH_KEYS/id_rsa_deploy" "/root/.ssh/id_rsa"
chmod ga-rwx "/root/.ssh/id_rsa"
chmod u+rw "/root/.ssh/id_rsa"

chown -R $SYSTEM_USER_NAME:$SERVER_USER_GROUP $BUILD_PATH_DIST
