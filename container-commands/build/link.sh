#!/usr/bin/env bash

dev_path=$BUILD_PATH_DIST
base_path=$BUILD_PATH_BASE

link_file () {
    file=$1

    if [[ ! -f "$dev_path/$file" ]]; then
        if [[ -f "$base_path/$file" ]]; then
            cp $base_path/$file $dev_path/$file
#        else
#            touch $dev_path/$file
        fi
    fi

    rm -f $base_path/$file
    ln -sf $dev_path/$file $base_path/$file
}

link_directory () {
    dir=$1

    if [[ ! -d "$dev_path/$dir" ]]; then
        if [[ -d "$base_path/$dir" ]]; then
            cp -r $base_path/$dir $dev_path/$dir
        else
            mkdir -p $dev_path/$dir
        fi
    fi

    rm -rf $base_path/$dir
    ln -sf $dev_path/$dir $base_path/$dir
}

mkdir -p $dev_path
find $base_path -type l -delete

if [[ -d "$dev_path" ]]; then
    echo "Linking dev files from $dev_path..."
    link_file composer.json
    link_file composer.lock
    link_directory Configuration

    if [[ -d "$dev_path/Packages" ]]; then
        echo "Linking dev packages..."
        for package_type_dir in $dev_path/Packages/*; do
            package_type=$(basename "$package_type_dir")
            echo "Linking dev packages of type '$package_type'..."

            if [[ ! -d "$base_path/Packages/$package_type" ]]; then
                mkdir -p "$base_path/Packages/$package_type"
            fi

            for package_dir in $package_type_dir/*; do
                package=$(basename "$package_dir")
                package_path="Packages/$package_type/$package"
                echo "Linking dev package '$package_path'..."
                link_directory $package_path
            done
        done
    fi
else
    echo "No dev files to link."
fi
