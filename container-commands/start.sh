#!/usr/bin/env bash

web_path=/var/www/html
dev_path=/usr/share/neos
base_path=/usr/share/neos-base
utils_path=/usr/share/neos-utils

base_repository="https://github.com/neos/neos-base-distribution.git"
if [[ -n "$BASE_REPOSITORY" ]]; then
    base_repository=$BASE_REPOSITORY
fi
#base_package="neos/neos-base-distribution:4.0.*"
#if [[ -n "$BASE_PACKAGE" ]]; then
#    base_package=$BASE_PACKAGE
#fi
#if [[ -n "$BASE_VERSION" ]]; then
#    base_package=$base_package:$BASE_VERSION
#fi

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
#if [[ -z "$NEOS_SITE_PACKAGE" ]]; then
#    export $NEOS_SITE_PACKAGE="Neos.Demo"
#fi

echo "Starting container in '$FLOW_CONTEXT' mode..."

if [[ "${FLOW_USER}" != "root" && $(grep -c "^${FLOW_USER}:" /etc/passwd) -eq 0 ]]; then
    adduser -q "${FLOW_USER}"
    usermod -a -G www-data "${FLOW_USER}"
fi

# install base package if missing
if [[ ! -f "$web_path/composer.json" && ! -f "$dev_path/composer.json" ]]; then
    echo ""
    echo "################################"
    echo "# No composer file detected"
    echo "# Initializing project"
    echo "# repository: $base_repository"
    if [[ -n "$BASE_VERSION" ]]; then
        echo "# version: $BASE_VERSION"
    fi
    echo "################################"
    echo ""
    mkdir -p $base_path
    git clone "$base_repository" $base_path
    if [ $? -ne 0 ]; then
        echo "git clone failed. aborting..."
        exit 1
    fi
    if [[ -n "$BASE_VERSION" ]]; then
        echo "checking out version '$BASE_VERSION'..."
        cd $base_path
        git checkout $BASE_VERSION
        if [ $? -ne 0 ]; then
            echo "version checkout failed. aborting..."
            exit 1
        fi
        cd $web_path
    fi

    cp -r $base_path/* $web_path
    #composer create-project $base_package /var/www/html
    mkdir -p $web_path/Data/Temporary
    mkdir -p $web_path/Data/Persistent
    #./flow core:setfilepermissions $FLOW_USER www-data www-data
fi

# link dev files
neos-utils link
if [ $? -ne 0 ]; then
    echo "neos-utils link failed. aborting..."
    exit 1
fi

cd $web_path

# project startup
if [[ ! -f composer.lock || ! -s composer.lock ]]; then
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
    echo "# setting file permissions"
    echo "# this may take a while..."
    echo "################################"
    echo ""
    ./flow core:setfilepermissions $FLOW_USER www-data www-data
else
    echo ""
    echo "################################"
    echo "# performing composer install..."
    echo "################################"
    echo ""
    composer install
fi
if [ $? -ne 0 ]; then
    echo "composer install failed. aborting..."
    exit 1
fi
echo "Flushing cache..."
rm -rf Data/Temporary
chown -R $FLOW_USER:www-data $web_path
chown -R $FLOW_USER:www-data $dev_path
ls -al

if [[ ! -f "$web_path/Configuration/$FLOW_CONTEXT/Settings.yaml" ]]; then
    echo ""
    echo "################################"
    echo "# no context settings file found"
    echo "# creating it..."
    echo "################################"
    echo ""
fi
envsubst < "$utils_path/Settings.yaml" > "$web_path/Configuration/$FLOW_CONTEXT/Settings.yaml"
if [ $? -ne 0 ]; then
	echo "couldn't write context settings file. aborting..."
	exit 1
fi

if [[ ! -f "$web_path/Configuration/Settings.yaml" && -n "$NEOS_SITE_PACKAGE" ]]; then
    echo ""
    echo "################################"
    echo "# no project settings file found"
    echo "# running setup..."
    echo "################################"
    echo ""

    #if [[ -n "$NEOS_SITE_PACKAGE" ]]; then
        # TODO: create site package
    #fi

	cp "$web_path/Configuration/Settings.yaml.example" "$web_path/Configuration/Settings.yaml"
	if [ $? -ne 0 ]; then
		echo "couldn't write default settings file. aborting..."
		exit 1
	fi
    ./flow doctrine:migrate
    ./flow site:import --package-key "$NEOS_SITE_PACKAGE"
    ./flow flow:cache:flush --force
    ./flow user:create "$FLOW_USER" "$FLOW_PASSWORD" "$FLOW_FIRSTNAME" "$FLOW_LASTNAME"
fi

# run apache
echo ""
echo "################################"
echo "# app initialized"
echo "# starting webserver..."
echo "################################"
echo ""
apache2-foreground
if [ $? -eq 0 ];then
   echo "Application stopped."
else
   echo "Apache crashed (exit code $?)!"
   exit 1
fi
