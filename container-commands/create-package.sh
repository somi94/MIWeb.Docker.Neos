#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "No package name given. Aborting..."
	exit 1
fi
package_key="$1"

dev_path="$BUILD_PATH_DIST"
package_dir="Packages/Application"

cd $BUILD_PATH_RELEASE

./flow site:kickstart "$package_key"

mkdir -p "$dev_path/$package_dir"
if [ $? -ne 0 ]; then
	echo "Creating package target path failed. Aborting..."
	exit 1
fi

mv "DistributionPackages/$package_key" "$dev_path/$package_dir/$package_key"
if [ $? -ne 0 ]; then
	echo "Moving package failed. Aborting..."
	exit 1
fi

neos-utils link
if [ $? -ne 0 ]; then
	echo "Link failed. Aborting..."
	exit 1
fi

composer update
if [ $? -ne 0 ]; then
	echo "Composer update failed. Aborting..."
	exit 1
fi
