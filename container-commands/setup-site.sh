#!/usr/bin/env bash

if [[ -z "$NEOS_SITE_PACKAGE" ]]; then
	echo "No site package defined, aborting site setup..."    
	exit 1
fi

web_path=$BUILD_PATH_RELEASE
dev_path=$BUILD_PATH_DIST
site="$NEOS_SITE_PACKAGE"
force_reimport="$1"

cd $web_path

if [[ -z "$NEOS_SITE_NAME" ]]; then
	site_name="New Neos Site"
else
	site_name="$NEOS_SITE_NAME"
fi

import=0
if [[ $(neos-utils flow site:list) == *" $site "* ]]; then
	echo "Site '$site' exists."
	
	import=$force_reimport
else
	echo "Site '$site' not found. Creating it using name '$site_name'..."

	./flow kickstart:site --site-name "$site_name" --package-key "$site"

	mv $web_path/DistributionPackages/$site $dev_path/Packages/Sites/$site
	
	import=1
fi

if [[ "$import" = "1" ]]; then
	echo "Importing site '$site'..."

	./flow site:prune '*'

	./flow site:import --package-key "$site"

	echo "Site import finished."
else
	echo "Site existed and no reimport was forced, skipped site import."
fi
