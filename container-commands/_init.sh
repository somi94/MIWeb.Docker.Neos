#!/usr/bin/env bash

# system variables
if [[ -z "$SYSTEM_USER_NAME" ]]; then
    export SYSTEM_USER_NAME="root"
fi
if [[ -z "$SYSTEM_USER_ID" ]]; then
    export SYSTEM_USER_ID=""
fi
if [[ -z "$DEV_USER_NAME" ]]; then
    export DEV_USER_NAME="$SYSTEM_USER_NAME"
fi
if [[ -z "$DEV_USER_ID" ]]; then
    export DEV_USER_ID="$SYSTEM_USER_ID"
fi

# server variables
if [[ -z "$SERVER_USER_NAME" ]]; then
    export SERVER_USER_NAME="root"
fi
if [[ -z "$SERVER_USER_GROUP" ]]; then
    export SERVER_USER_GROUP="www-data"
fi

# mysql variables
if [[ -z "$MYSQL_HOST" ]]; then
    export MYSQL_HOST="db"
fi

# smtp variables
if [[ -z "$SMTP_PORT" ]]; then
    export SMTP_PORT="465"
fi
if [[ -z "$SMTP_ENCRYPTION" ]]; then
    export SMTP_ENCRYPTION="ssl"
fi

# build variables
if [[ -z "$BUILD_PATH_RELEASE" ]]; then
    export BUILD_PATH_RELEASE="/var/www/html"
fi
if [[ -z "$BUILD_PATH_DIST" ]]; then
    export BUILD_PATH_DIST="/usr/share/neos/project"
fi
if [[ -z "$BUILD_PATH_BASE" ]]; then
    export BUILD_PATH_BASE="/usr/share/neos/build"
fi
if [[ -z "$BUILD_PATH_DATA" ]]; then
    export BUILD_PATH_DATA="/usr/share/neos/data"
fi
if [[ -z "$BUILD_PATH_KEYS" ]]; then
    export BUILD_PATH_KEYS="/usr/share/neos/keys"
fi
if [[ -z "$BUILD_PATH_UTILS" ]]; then
    export BUILD_PATH_UTILS="/usr/share/neos-utils"
fi
if [[ -z "$BUILD_REPOSITORY" ]]; then
    export BUILD_REPOSITORY="https://github.com/neos/neos-base-distribution.git"
fi

# flow variables
if [[ -z "$FLOW_CONTEXT" ]]; then
    export FLOW_CONTEXT="Development"
fi
#if [[ -z "$NEOS_USER_NAME" ]]; then
#    export NEOS_USER_NAME=root
#fi
if [[ -z "$NEOS_USER_PASSWORD" && -n "$NEOS_USER_NAME" ]]; then
    export NEOS_USER_PASSWORD="$NEOS_USER_NAME"
fi
if [[ -z "$NEOS_USER_FIRSTNAME" ]]; then
    export NEOS_USER_FIRSTNAME="Firstname"
fi
if [[ -z "$NEOS_USER_LASTNAME" ]]; then
    export NEOS_USER_LASTNAME="Lastname"
fi

# site variables
if [[ -z "$NEOS_SITE_NAME" ]]; then
    export NEOS_SITE_NAME="New Neos Site"
fi
if [[ -z "$NEOS_SITE_REIMPORT" ]]; then
    export NEOS_SITE_REIMPORT=0
fi
