#!/usr/bin/env bash

site="$NEOS_SITE_PACKAGE"

if [[ ! -d "$BUILD_PATH_BASE/Packages/Sites/$site" || ! -d "$BUILD_PATH_DIST/Packages/$site" ]]; then
	echo "Site '$site' not found, aborting..."
	exit 1
fi

./flow site:prune '*'
./flow site:import --package-key "$site"
./flow flow:cache:flush --force