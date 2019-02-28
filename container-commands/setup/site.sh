#!/usr/bin/env bash

if [[ -z "$NEOS_SITE_PACKAGE" ]]; then
	echo "No site package defined, aborting site setup..."    
	exit 1
fi

dev_path=$BUILD_PATH_DIST
site="$NEOS_SITE_PACKAGE"
site_name="$NEOS_SITE_NAME"
force_reimport="$1"

cd $BUILD_PATH_BASE

if [[ -z "$force_reimport" ]]; then
    force_reimport="$NEOS_SITE_REIMPORT"
fi

import=0
if [[ $(./flow site:list) == *" $site "* ]]; then
	echo "Site '$site' exists."
	
	import=$force_reimport
elif [[ -d "$BUILD_PATH_BASE/Packages/Sites/$site" || -d "$BUILD_PATH_DIST/Packages/$site" ]]; then
    echo "Site '$site' exists, but hasn't been imported yet."
    import=1
else
	echo "Site '$site' not found. Creating it using name '$site_name'..."

	neos-utils kickstart package "$site" "Site" "$site_name"
	
	import=1
fi

if [[ "$import" = "1" ]]; then
	echo "Importing site '$site'..."

	./flow site:prune '*'

	./flow resource:clean

	./flow flow:cache:flush --force

	./flow site:import --package-key "$site"

	./flow resource:publish 

	neos-utils setup filepermissions

	echo "Site import finished."
else
	echo "Site existed and no reimport was forced, skipped site import."

	# ./flow resource:publish
fi
