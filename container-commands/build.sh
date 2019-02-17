#!/usr/bin/env bash

echo "Starting build..."
neos-utils build base

echo "Linking build..."
rm -rf "$BUILD_PATH_RELEASE"
ln -s "$BUILD_PATH_BASE" "$BUILD_PATH_RELEASE"

echo "Build finished."
