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
    echo "git clone failed. aborting..."
    exit 1
fi

cd $BUILD_PATH_BASE

if [[ -n "$BUILD_VERSION" ]]; then
    echo "checking out version '$BUILD_VERSION'..."
    git checkout $BUILD_VERSION
    if [ $? -ne 0 ]; then
        echo "version checkout failed. aborting..."
        exit 1
    fi
fi

mkdir -p Data/Temporary
mkdir -p Data/Persistent

echo ""
echo "################################"
echo "# performing composer update"
echo "################################"
echo ""
composer update
echo ""
echo "################################"
echo "# applying file permissions"
echo "################################"
echo ""
./flow core:setfilepermissions $BUILD_USER www-data www-data

echo ""
echo "################################"
echo "# applying file permissions"
echo "################################"
echo ""
cp -r $BUILD_PATH_BASE/* $BUILD_PATH_RELEASE
