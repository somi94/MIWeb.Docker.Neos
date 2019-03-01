#!/usr/bin/env bash

cd "$BUILD_PATH_BASE"

# TODO: remove old dev packages?

chown -R $SYSTEM_USER_NAME:www-data "$BUILD_PATH_DIST"

if [[ -z "$DEV_PACKAGE_LIST" ]]; then
    echo "No dev packages defined, skipping dev setup..."
    exit 0
fi

update=0

for dev_entry in "$DEV_PACKAGE_LIST"
do
    if [[ "$dev_entry" =~ ^([^:]*):(.*)$ ]]; then
        dev_package=${BASH_REMATCH[1]}
        dev_repo=${BASH_REMATCH[2]}
        echo "Updating dev package '$dev_package' (repository: '$dev_repo')..."

        dev_path="$BUILD_PATH_DIST/Packages/$dev_package"

        if [[ -d "$dev_path" ]]; then
            echo "Dev package '$dev_package' already exists."
        else
            echo "Removing installed package (if any)..."
            rm -rf "$BUILD_PATH_BASE/Packages/*/$dev_package/"

            echo "Cloning '$dev_repo'..."
            git clone "$dev_repo" "$dev_path"

            echo "Adding '$dev_package' to .gitignore..."
            echo "/$dev_path" >> "$BUILD_PATH_DIST/Packages/.gitignore"

            # chown -R

            update=1
        fi
    else
        echo "Dev package '$dev_entry' definition is invalid...";
    fi
done

chown -R $SYSTEM_USER_NAME:www-data "$BUILD_PATH_DIST"

if [[ "$update" = "1" ]]; then
    echo "Dev package(s) changed, refreshing environment..."

    ./flow flow:cache:flush --force

    composer update
fi