#!/usr/bin/env bash

cd $BUILD_PATH_BASE

checksum="[none]"

if [[ -d "$BUILD_PATH_DIST" ]]; then
    chown -R "$SYSTEM_USER_NAME":www-data "$BUILD_PATH_DIST"
    chmod -R g+rwx "$BUILD_PATH_DIST"

    checksum=$(find "$BUILD_PATH_DIST" -type f -name composer\.json -exec md5sum '{}' \; | md5sum | awk '{ print $1 }')
fi

#checksum=$(find "$BUILD_PATH_DIST" -type f -exec md5sum '{}' \; | md5sum | awk '{ print $1 }')
checksum_file="$BUILD_PATH_BASE/.dist"

if [[ "$1" = "--force" ]]; then
	echo "Forcing dist update..."
elif [[ -f "$checksum_file" ]]; then
	if [[ $(cat "$checksum_file") = "$checksum"	]]; then
		echo "Dist is up to date, no update required."
		exit 0
	else
		echo "Dist is outdated, update required."
	fi
else
	echo "No dist checksum found, update required."
fi

echo "Linking dev files..."
neos-utils build link
if [ $? -ne 0 ]; then
    echo "Linking files failed. Aborting..."
    exit 1
fi

echo "Performing composer update..."
composer update
if [ $? -ne 0 ]; then
    echo "Composer update failed. Aborting..."
    exit 1
fi

#echo "Re-Linking dev files..."
#neos-utils build link
#if [ $? -ne 0 ]; then
#    echo "Re-Linking files failed. Aborting..."
#    exit 1
#fi

echo "Flushing cache..."
rm -rf Data/Temporary
./flow flow:cache:flush --force

neos-utils setup filepermissions

echo "$checksum" > "$checksum_file"
echo "Build update finished."
