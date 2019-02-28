#!/usr/bin/env bash

cd $BUILD_PATH_BASE

echo "Creating context settings..."
mkdir -p "$BUILD_PATH_BASE/Configuration/$FLOW_CONTEXT"
envsubst < "$BUILD_PATH_UTILS/Settings.yaml" > "$BUILD_PATH_BASE/Configuration/$FLOW_CONTEXT/Settings.Build.yaml"
if [ $? -ne 0 ]; then
    echo "Couldn't write context settings file. aborting..."
    exit 1
fi
chown "$SERVER_USER_NAME":www-data "$BUILD_PATH_BASE/Configuration/$FLOW_CONTEXT/Settings.Build.yaml"

if [[ ! -f "$BUILD_PATH_BASE/Configuration/Settings.yaml" ]]; then
    echo "No project settings file found. Creating default settings..."

	cp "$BUILD_PATH_BASE/Configuration/Settings.yaml.example" "$BUILD_PATH_BASE/Configuration/Settings.yaml"
	if [ $? -ne 0 ]; then
		echo "Couldn't write default settings file. aborting..."
		exit 1
	fi
fi

echo "Migrating database..."
./flow doctrine:migrate
if [ $? -ne 0 ]; then
    echo "Database migration failed. Aborting..."
    exit 1
fi

echo "Updating data ownership (user: '$SERVER_USER_NAME')..."
chown -R "$SERVER_USER_NAME":www-data $BUILD_PATH_BASE/Data
chmod -R ug+rwx $BUILD_PATH_BASE/Data
if [ $? -ne 0 ]; then
    echo "Updating data ownership failed. Aborting..."
    exit 1
fi
