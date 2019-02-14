#!/usr/bin/env bash

# setup webserver user (username equals flow username)
user="root"
if [[ "$SYSTEM_USER_NAME" != "root" && $(grep -c "^$SYSTEM_USER_NAME:" /etc/passwd) -eq 0 ]]; then
	echo ""
    echo "#####################################"
    echo "# Adding system user '$SYSTEM_USER_NAME'"
    echo "#####################################"
	echo ""

    adduser -q "$SYSTEM_USER_NAME"
    usermod -a -G www-data "$SYSTEM_USER_NAME"
fi

# checkout base package
if [[ ! -f "$BUILD_PATH_BASE/composer.json" ]]; then
    neos-utils build-base
	if [ $? -ne 0 ]; then
		echo "Base build failed. aborting..."
		exit 1
	fi
fi

# link dev files
echo ""
echo "################################"
echo "# Linking dev files..."
echo "################################"
echo ""
neos-utils link
if [ $? -ne 0 ]; then
    echo "Linking files failed. aborting..."
    exit 1
fi

# cd to release dir
cd "$BUILD_PATH_RELEASE"

# perform composer update/install
if [[ ! -f composer.lock && ! -s composer.lock ]]; then
    echo ""
    echo "################################"
    echo "# no composer lock file found"
    echo "# performing composer update"
    echo "# this may take a while..."
    echo "################################"
    echo ""
    composer update
	if [ $? -ne 0 ]; then
		echo "Composer update failed. aborting..."
		exit 1
	fi
    echo ""
    echo "################################"
    echo "# Applying file permissions..."
    echo "################################"
    echo ""
    ./flow core:setfilepermissions $SYSTEM_USER_NAME www-data www-data
	if [ $? -ne 0 ]; then
		echo "Updating file permissions failed. aborting..."
		exit 1
	fi
else
    echo ""
    echo "################################"
    echo "# Performing composer install..."
    echo "################################"
    echo ""
    composer install
	if [ $? -ne 0 ]; then
		echo "Composer install failed. aborting..."
		exit 1
	fi
fi

echo ""
echo "################################"
echo "# Flushing cache..."
echo "################################"
echo ""
rm -rf Data/Temporary
chown -R $SYSTEM_USER_NAME:www-data $BUILD_PATH_RELEASE
chown -R $SYSTEM_USER_NAME:www-data $BUILD_PATH_DIST

echo ""
echo "################################"
echo "# Creating context settings..."
echo "################################"
echo ""
envsubst < "$BUILD_PATH_UTILS/Settings.yaml" > "$BUILD_PATH_RELEASE/Configuration/$FLOW_CONTEXT/Settings.Build.yaml"
if [ $? -ne 0 ]; then
    echo "couldn't write context settings file. aborting..."
    exit 1
fi

if [[ ! -f "$BUILD_PATH_RELEASE/Configuration/Settings.yaml" ]]; then
    echo ""
    echo "################################"
    echo "# No project settings file found."
    echo "# Creating default settings..."
    echo "################################"
    echo ""

	cp "$BUILD_PATH_RELEASE/Configuration/Settings.yaml.example" "$BUILD_PATH_RELEASE/Configuration/Settings.yaml"
	if [ $? -ne 0 ]; then
		echo "Couldn't write default settings file. aborting..."
		exit 1
	fi
fi
