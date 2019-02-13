. ./config.sh

# setup webserver user (username equals flow username)
if [[ "$FLOW_USER" != "root" && $(grep -c "^$FLOW_USER:" /etc/passwd) -eq 0 ]]; then
    echo "#####################################"
    echo "# Adding system user '$FLOW_USER'"
    echo "#####################################"

    adduser -q "$FLOW_USER"
    usermod -a -G www-data "$FLOW_USER"
fi

# checkout base package
#if [[ ! -f "$BUILD_PATH_BASE/composer.json" ]]; then
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
    if [[ -n "$BUILD_VERSION" ]]; then
        echo "checking out version '$BUILD_VERSION'..."
        cd $BUILD_PATH_BASE
        git checkout $BUILD_VERSION
        if [ $? -ne 0 ]; then
            echo "version checkout failed. aborting..."
            exit 1
        fi
    fi
    
    mkdir -p $BUILD_PATH_BASE/Data/Temporary
    mkdir -p $BUILD_PATH_BASE/Data/Persistent

    cp -r $BUILD_PATH_BASE/* $BUILD_PATH_RELEASE
#fi

# link dev files
echo ""
echo "################################"
echo "# Linking dev files..."
echo "################################"
neos-utils link
if [ $? -ne 0 ]; then
    echo "neos-utils link failed. aborting..."
    exit 1
fi

# cd to release dir
cd "$BUILD_PATH_RELEASE"

# perform composer update/install
if [[ ! -f composer.lock && ! -s composer.lock ]]; then
    echo ""
    echo "################################"
    echo "# no composer lock file found"
    echo "# performing composer update"
    echo "# this may take a while..."
    echo "################################"
    echo ""
    composer update
    echo ""
    echo "################################"
    echo "# Applying file permissions..."
    echo "################################"
    echo ""
    ./flow core:setfilepermissions $FLOW_USER www-data www-data
else
    echo ""
    echo "################################"
    echo "# Performing composer install..."
    echo "################################"
    echo ""
    composer install
fi
if [ $? -ne 0 ]; then
    echo "composer install failed. aborting..."
    exit 1
fi

echo ""
echo "################################"
echo "# Flushing cache..."
echo "################################"
rm -rf Data/Temporary
chown -R $FLOW_USER:www-data $BUILD_PATH_RELEASE
chown -R $FLOW_USER:www-data $BUILD_PATH_DIST

echo ""
echo "################################"
echo "# Creating context settings..."
echo "################################"
echo ""
envsubst < "$BUILD_PATH_UTILS/Settings.yaml" > "$BUILD_PATH_RELEASE/Configuration/$FLOW_CONTEXT/Settings.Build.yaml"
if [ $? -ne 0 ]; then
    echo "couldn't write context settings file. aborting..."
    exit 1
fi

if [[ ! -f "$web_path/Configuration/Settings.yaml" ]]; then
    echo ""
    echo "################################"
    echo "# No project settings file found."
    echo "# Creating default settings..."
    echo "################################"
    echo ""

	cp "$BUILD_PATH_RELEASE/Configuration/Settings.yaml.example" "$BUILD_PATH_RELEASE/Configuration/Settings.yaml"
	if [ $? -ne 0 ]; then
		echo "Couldn't write default settings file. aborting..."
		exit 1
	fi
fi
