#!/usr/bin/env bash

cd $BUILD_PATH_BASE

echo "Creating context settings..."
envsubst < "$BUILD_PATH_UTILS/Settings.yaml" > "$BUILD_PATH_BASE/Configuration/$FLOW_CONTEXT/Settings.Build.yaml"
if [ $? -ne 0 ]; then
    echo "Couldn't write context settings file. aborting..."
    exit 1
fi

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
