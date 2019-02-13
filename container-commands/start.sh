#!/usr/bin/env bash

neos-utils build

cd $BUILD_PATH_RELEASE

echo ""
echo "################################"
echo "# Migrating database..."
echo "################################"
echo ""
./flow doctrine:migrate

echo ""
echo "################################"
echo "# Updating site..."
echo "################################"
echo ""
neos-utils setup-site

echo ""
echo "################################"
echo "# Flushing cache..."
echo "################################"
echo ""
./flow flow:cache:flush --force

echo ""
echo "################################"
echo "# Updating user..."
echo "################################"
echo ""
neos-utils setup-user

# run apache
echo ""
echo "################################"
echo "# app initialized"
echo "# starting webserver..."
echo "################################"
echo ""
apache2-foreground
if [ $? -eq 0 ];then
   echo "Application stopped."
else
   echo "Apache crashed (exit code $?)!"
   exit 1
fi
