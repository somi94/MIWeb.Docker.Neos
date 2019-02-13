#!/usr/bin/env bash

# build variables
if [[ -z "$BUILD_PATH_RELEASE" ]]; then
  export BUILD_PATH_RELEASE=/var/www/html
fi
if [[ -z "$BUILD_PATH_DIST" ]]; then
  export BUILD_PATH_DIST=/usr/share/neos-project
fi
if [[ -z "$BUILD_PATH_BASE" ]]; then
  export BUILD_PATH_BASE=/usr/share/neos-base
fi
if [[ -z "$BUILD_PATH_UTILS" ]]; then
  export BUILD_PATH_UTILS=/usr/share/neos-utils
fi
if [[ -z "$BUILD_REPOSITORY" ]]; then
    export BUILD_REPOSITORY="https://github.com/neos/neos-base-distribution.git"
fi

# flow variables
if [[ -z "$FLOW_CONTEXT" ]]; then
    export FLOW_CONTEXT=Development
fi
if [[ -z "$NEOS_USER_NAME" ]]; then
    export NEOS_USER_NAME=root
fi
if [[ -z "$NEOS_USER_PASSWORD" ]]; then
    export NEOS_USER_PASSWORD=root
fi
if [[ -z "$NEOS_USER_FIRSTNAME" ]]; then
    export NEOS_USER_FIRSTNAME="Firstname"
fi
if [[ -z "$NEOS_USER_LASTNAME" ]]; then
    export NEOS_USER_LASTNAME="Lastname"
fi
