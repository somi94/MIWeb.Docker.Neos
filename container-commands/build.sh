#!/usr/bin/env bash

echo "Starting build..."
neos-utils build base
if [ $? -ne 0 ]; then
    echo "Base build failed. Aborting..."
    exit 1
fi

echo "Linking build..."
rm -rf "$BUILD_PATH_RELEASE"
ln -s "$BUILD_PATH_BASE" "$BUILD_PATH_RELEASE"

echo "Build finished."
