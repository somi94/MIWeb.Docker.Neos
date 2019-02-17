#!/usr/bin/env bash

echo "Setting up system..."
neos-utils setup system
if [ $? -ne 0 ]; then
    echo "System setup failed. Aborting..."
    exit 1
fi

echo "Starting build..."
neos-utils build
if [ $? -ne 0 ]; then
    echo "Build failed. Aborting..."
    exit 1
fi

neos-utils setup app

if [[ -n "$NEOS_SITE_PACKAGE" ]]; then
	echo "Setting up site..."
	neos-utils setup site
	if [ $? -ne 0 ]; then
		echo "Site setup failed. Aborting..."
		exit 1
	fi
else
	echo "No site defined, skipping site setup..."
fi

if [[ -n "$NEOS_USER_NAME" ]]; then
	echo "Setting up user..."
	neos-utils setup user
	if [ $? -ne 0 ]; then
		echo "User setup failed. Aborting..."
		exit 1
	fi
else
	echo "No user defined, skipping user setup..."
fi

echo "Setup finished."
