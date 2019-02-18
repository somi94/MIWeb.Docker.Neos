#!/usr/bin/env bash

neos-utils build
if [ $? -ne 0 ]; then
    echo "Build failed. Aborting..."
    exit 1
fi

cd $BUILD_PATH_RELEASE

echo ""
echo "################################"
echo "# Migrating database..."
echo "################################"
echo ""
./flow doctrine:migrate
if [ $? -ne 0 ]; then
    echo "Database migration failed. Aborting..."
    exit 1
fi

if [[ -n "$NEOS_SITE_PACKAGE" ]]; then
	echo ""
	echo "################################"
	echo "# Updating site..."
	echo "################################"
	echo ""
	neos-utils setup-site
	if [ $? -ne 0 ]; then
		echo "Site setup failed. Aborting..."
		exit 1
	fi
else
	echo ""
	echo "No site package defined, skipping site setup..."
	echo ""
fi

echo ""
echo "################################"
echo "# Flushing cache..."
echo "################################"
echo ""
./flow flow:cache:flush --force

if [[ -n "$NEOS_USER_NAME" ]]; then
	echo ""
	echo "################################"
	echo "# Updating user..."
	echo "################################"
	echo ""
	neos-utils setup-user
	if [ $? -ne 0 ]; then
		echo "User setup failed. Aborting..."
		exit 1
	fi
else
	echo ""
	echo "No user defined, skipping user setup..."
	echo ""
fi

# run apache
echo ""
echo "################################"
echo "# app initialized"
echo "# starting webserver..."
echo "################################"
echo ""
runuser -l "$SYSTEM_USER_NAME" -c 'apache2-foreground'
if [ $? -eq 0 ];then
   echo "Application stopped."
else
   echo "Apache crashed (exit code $?)!"
   exit 1
fi
