#!/usr/bin/env bash

echo "Starting system build..."
neos-utils build system
if [ $? -ne 0 ]; then
    echo "System build failed. Aborting..."
    exit 1
fi

echo "Starting base build..."
neos-utils build base
if [ $? -ne 0 ]; then
    echo "Base build failed. Aborting..."
    exit 1
fi
# chown -R root:www-data "$BUILD_PATH_RELEASE/.."

echo "Build finished."
