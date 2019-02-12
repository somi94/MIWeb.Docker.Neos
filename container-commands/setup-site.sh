#!/usr/bin/env bash

if [[ -z "$NEOS_SITE_PACKAGE" ]]; then
	echo "No site package defined, aborting site setup..."    
	exit 1
fi

web_path=/var/www/html
dev_path=/usr/share/neos
site="$NEOS_SITE_PACKAGE"

if [[ -z "$NEOS_SITE_NAME" ]]; then
	site_name="New Neos Site"
else
	site_name="$NEOS_SITE_NAME"
fi

if [[ $(neos-utils flow site:list) == *" $site "* ]]; then
	echo "Site '$site' exists."
else
	echo "Site '$site' not found. Creating it using name '$site_name'..."

	neos-utils flow kickstart:site --site-name "$site_name" --package-key "$site"

	mv $web_path/DistributionPackages/$site $dev_path/Packages/Sites/$site
fi

echo "Importing site '$site'..."

neos-utils flow site:prune '*'

neos-utils flow site:import --package-key "$site"

echo "Site import finished."
