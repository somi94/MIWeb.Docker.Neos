#!/usr/bin/env bash

if [[ -z "$1" ]]; then
	echo "No package name given. Aborting..."
	exit 1
fi
package_key="$1"
package_type="Application"
if [[ -n "$2" ]]; then
	package_type="$2"
fi

echo "Creating package '$package_key' of type '$package_type'..."

dev_path="$BUILD_PATH_DIST"
package_dir="Packages/$package_type"

cd $BUILD_PATH_RELEASE

if [[ $package_type = "Site" ]]; then
	site_name="New Neos Site"
	if [[ -n "$3" ]]; then
		site_name="$3"
	fi
	echo "Kickstarting site '$package_key', using name '$site_name'..."
	./flow kickstart:site --site-name "$site_name" --package-key "$package_key"
else
	echo "Kickstarting package '$package_key'..."
	./flow kickstart:package "$package_key"
fi

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
