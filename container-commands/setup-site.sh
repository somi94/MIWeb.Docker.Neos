#!/usr/bin/env bash

if [[ -z "$NEOS_SITE_PACKAGE" ]]; then
	echo "No site package defined, aborting site setup..."    
	exit 1
fi

web_path=$BUILD_PATH_RELEASE
dev_path=$BUILD_PATH_DIST
site="$NEOS_SITE_PACKAGE"

cd $web_path

if [[ -z "$NEOS_SITE_NAME" ]]; then
	site_name="New Neos Site"
else
	site_name="$NEOS_SITE_NAME"
fi

if [[ $(neos-utils flow site:list) == *" $site "* ]]; then
	echo "Site '$site' exists."
else
	echo "Site '$site' not found. Creating it using name '$site_name'..."

	./flow kickstart:site --site-name "$site_name" --package-key "$site"

	mv $web_path/DistributionPackages/$site $dev_path/Packages/Sites/$site
fi

echo "Importing site '$site'..."

./flow site:prune '*'

./flow site:import --package-key "$site"

echo "Site import finished."
