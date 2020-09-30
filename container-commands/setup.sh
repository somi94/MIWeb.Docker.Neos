#!/usr/bin/env bash

if [[ ! -f "$BUILD_PATH_BASE/.build" ]]; then
    echo "Warning: no build found, starting build which might not desirable in production environment..."
    neos-utils build
    if [ $? -ne 0 ]; then
        echo "Build failed. Aborting..."
        exit 1
    fi
elif [[ ! -f "$BUILD_PATH_BASE/.dist" ]]; then
    echo "Warning: no dist found, starting build update which might not desirable in production environment..."
    neos-utils build update
    if [ $? -ne 0 ]; then
        echo "Build update failed. Aborting..."
        exit 1
    fi
fi

echo "Updating dev packages..."
neos-utils build dev
if [[ $? -ne 0 ]]; then
    echo "Dev package update failed. Aborting..."
    exit 1
fi

ready_check_counter="0"
ready_check_max_attempts="10"
ready_check_sleep="3"
while [[ "$ready_check_counter" -lt "$ready_check_max_attempts" ]]; do
    ready_check_attempt="$ready_check_counter"+1
    echo "Waiting for environment to become ready ($ready_check_attempt / $ready_check_max_attempts) ..."
    ready_check_result=$(php /ready.php)
    if [[ "$ready_check_result" -eq "ready" ]]; then
        echo "Environment is ready. Continuing ..."
        break
    elif [[ "$ready_check_attempt" -eq "$ready_check_max_attempts" ]]; then
        echo "Environment is not ready. Ready check result:"
        echo "$ready_check_result"
        echo "Ready check failed $ready_check_max_attempts times. Aborting ..."
        exit 1
    else
        echo "Environment is not ready. Ready check result:"
        echo "$ready_check_result"
        echo "Sleeping for ${ready_check_sleep}s ..."
        sleep "$ready_check_sleep"
        ready_check_counter="$ready_check_counter"+1
    fi
done

neos-utils setup app
if [ $? -ne 0 ]; then
    echo "App setup failed. Aborting..."
    exit 1
fi

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

neos-utils setup protection
if [ $? -ne 0 ]; then
    echo "Webserver protection setup failed. Aborting..."
    exit 1
fi

echo "Linking build..."
rm -rf "$BUILD_PATH_RELEASE"
ln -s "$BUILD_PATH_BASE" "$BUILD_PATH_RELEASE"

echo "Setup finished."

if [[ -n "$RUNNER_COMMAND" ]]; then
    echo "Starting runner..."
    neos-utils runner &
fi
