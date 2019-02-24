#!/usr/bin/env bash

container_user="root"
if [[ -n "$1" ]]; then
	container_user="$1"
elif [[ -n "$USER" ]]; then
	container_user="$USER"
fi

echo "Applying file permissions (user: '$container_user')..."
#chown -R $SYSTEM_USER_NAME:www-data $BUILD_PATH_RELEASE
#chown -R $SYSTEM_USER_NAME:www-data $BUILD_PATH_DIST
#./flow core:setfilepermissions $SYSTEM_USER_NAME www-data www-data
./flow core:setfilepermissions $container_user www-data www-data
