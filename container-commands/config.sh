# build variables
if [[ -z "$BUILD_PATH_RELEASE" ]]; then
  export $BUILD_PATH_RELEASE=/var/www/html
fi
if [[ -z "$BUILD_PATH_DIST" ]]; then
  export $BUILD_PATH_DIST=/usr/share/neos
fi
if [[ -z "$BUILD_PATH_BASE" ]]; then
  export $BUILD_PATH_BASE=/usr/share/neos-base
fi
if [[ -z "$BUILD_PATH_UTILS" ]]; then
  export $BUILD_PATH_UTILS=/usr/share/neos-utils
fi
if [[ -z "$BUILD_REPOSITORY" ]]; then
    export $BUILD_REPOSITORY="https://github.com/neos/neos-base-distribution.git"
fi

# flow variables
if [[ -z "$FLOW_CONTEXT" ]]; then
    export $FLOW_CONTEXT=Development
fi
if [[ -z "$FLOW_USER" ]]; then
    export $FLOW_USER=root
fi
if [[ -z "$FLOW_PASSWORD" ]]; then
    export $FLOW_PASSWORD=root
fi
if [[ -z "$FLOW_FIRSTNAME" ]]; then
    export $FLOW_FIRSTNAME="Firstname"
fi
if [[ -z "$FLOW_FIRSTNAME" ]]; then
    export $FLOW_FIRSTNAME="Lastname"
fi
