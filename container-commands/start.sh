#!/usr/bin/env bash

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
echo "# Updating setup user..."
echo "################################"
echo ""
# TODO: don't do this on every start (alter user info if already existing)
#./flow user:create "$FLOW_USER" "$FLOW_PASSWORD" "$FLOW_FIRSTNAME" "$FLOW_LASTNAME"

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
