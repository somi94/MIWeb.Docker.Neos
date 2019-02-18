#!/usr/bin/env bash

build_info="$BUILD_REPOSITORY:$BUILD_VERSION"
build_info_file="$BUILD_PATH_BASE/.build"

if [[ "$1" = "--force" ]]; then
	echo "Forcing full build..."
elif [[ -f "$build_info_file" && $(cat "$build_info_file") = "$build_info" ]]; then
	echo "Basic build info matches (repository & version) checking build rev..."
	build_rev_path="HEAD"
	if [[ -n "$BUILD_VERSION" ]]; then
		build_rev_path="$BUILD_VERSION"
	fi

	build_rev="[none]"
	if [[ -d "$BUILD_PATH_BASE/.git" ]]; then
		cd "$BUILD_PATH_BASE"
		build_rev=$(git rev-parse "$build_rev_path")
		if [ $? -ne 0 ]; then
			echo "Couldn't parse build rev for path '$build_rev_path'. Aborting..."
			exit 1
		fi
	fi

	if [[ $(git rev-parse origin "$build_rev_path") == *"$build_rev"* ]]; then
		echo "Current build rev '$build_rev' is up to date."
		neos-utils build update		
		exit 0
	else
		echo "Current build rev '$build_rev' is outdated."
	fi
else
	echo "Build is not existent or outdated, performing full build..."
fi

echo "Setting up build dir..."
mkdir -p $BUILD_PATH_BASE
find $BUILD_PATH_BASE -type l -delete
rm -rf $BUILD_PATH_BASE/*
cd $BUILD_PATH_BASE

echo "Performing git clone..."
git clone "$BUILD_REPOSITORY" $BUILD_PATH_BASE
if [ $? -ne 0 ]; then
    echo "Git clone failed. Aborting..."
    exit 1
fi

if [[ -n "$BUILD_VERSION" ]]; then
    echo "Checking out version '$BUILD_VERSION'..."
    git checkout $BUILD_VERSION
    if [ $? -ne 0 ]; then
        echo "Version checkout failed. Aborting..."
        exit 1
    fi
fi

echo "Creating project directories..."
mkdir -p Data/Temporary
mkdir -p Data/Persistent

echo "Updating build..."
neos-utils build update --force
if [ $? -ne 0 ]; then
    echo "Build update failed. Aborting..."
    exit 1
fi

echo "$build_info" > "$build_info_file"

