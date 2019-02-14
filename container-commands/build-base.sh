#!/usr/bin/env bash

echo ""
echo "################################"
echo "# Setting up base distribution"
echo "# repository: $BUILD_REPOSITORY"
if [[ -n "$BUILD_VERSION" ]]; then
    echo "# version: $BUILD_VERSION"
fi
echo "################################"
echo ""

mkdir -p $BUILD_PATH_BASE

git clone "$BUILD_REPOSITORY" $BUILD_PATH_BASE
if [ $? -ne 0 ]; then
    echo "Git clone failed. Aborting..."
    exit 1
fi

cd $BUILD_PATH_BASE

if [[ -n "$BUILD_VERSION" ]]; then
    echo "checking out version '$BUILD_VERSION'..."
    git checkout $BUILD_VERSION
    if [ $? -ne 0 ]; then
        echo "Version checkout failed. Aborting..."
        exit 1
    fi
fi

mkdir -p Data/Temporary
mkdir -p Data/Persistent

echo ""
echo "################################"
echo "# Performing base composer update"
echo "################################"
echo ""
composer update
if [ $? -ne 0 ]; then
    echo "Composer update failed. Aborting..."
    exit 1
fi
echo ""
echo "################################"
echo "# Applying base file permissions"
echo "################################"
echo ""
./flow core:setfilepermissions $BUILD_USER www-data www-data
if [ $? -ne 0 ]; then
    echo "Setting base file permissions failed. Aborting..."
    exit 1
fi

echo ""
echo "################################"
echo "# Releasing base files"
echo "################################"
echo ""
cp -r $BUILD_PATH_BASE/* $BUILD_PATH_RELEASE
if [ $? -ne 0 ]; then
    echo "Base file release failed. Aborting..."
    exit 1
fi
