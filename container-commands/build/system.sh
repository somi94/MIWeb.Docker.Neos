#!/usr/bin/env bash

# setup users
neos-utils build system-user $SYSTEM_USER_NAME $SYSTEM_USER_ID
if [ $? -ne 0 ]; then
	echo "Adding system user '$SYSTEM_USER_NAME' (id: '$SYSTEM_USER_ID') failed. Aborting..."
    exit 1
fi

neos-utils build system-user $SERVER_USER_NAME $SERVER_USER_ID
if [ $? -ne 0 ]; then
    echo "Adding server user '$SERVER_USER_NAME' (id: '$SERVER_USER_ID') failed. Aborting..."
    exit 1
fi

# TODO: find a better fix for host key verification issue
echo "Setting up ssh config..."
echo "Host *" >> "/root/.ssh/config"
echo "    StrictHostKeyChecking no" >> "/root/.ssh/config"
chmod ga-rwx "/root/.ssh/config"
chmod u+rw "/root/.ssh/config"

if [[ -d "$BUILD_PATH_DIST" ]]; then
    echo "Applying project file permissions (user: '$SYSTEM_USER_NAME', group: '$SERVER_USER_GROUP')..."
    chown -R $SYSTEM_USER_NAME:$SERVER_USER_GROUP $BUILD_PATH_DIST
fi

if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "Configuring github token..."
    composer config --global github-oauth.github.com "$GITHUB_TOKEN"
else
    echo "No github token given, skipping token configuration..."
fi