#!/usr/bin/env bash

if [[ -z "$NEOS_USER_NAME" ]]; then
	echo "No user defined, aborting user setup..."    
	exit 1
fi

cd $BUILD_PATH_RELEASE

if [[ $(./flow user:list) == *" $NEOS_USER_NAME "* ]]; then
	echo "User '$NEOS_USER_NAME' exists, updating password..."
	./flow user:setpassword "$NEOS_USER_NAME" "$NEOS_USER_PASSWORD"
else
	echo "Couldn't find user '$NEOS_USER_NAME', creating it..."
	./flow user:create "$NEOS_USER_NAME" "$NEOS_USER_PASSWORD" "$NEOS_USER_FIRSTNAME" "$NEOS_USER_LASTNAME"
fi

echo "User setup finished."
