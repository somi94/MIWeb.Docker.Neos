#!/usr/bin/env bash

web_path=/var/www/html
dev_path=/usr/share/neos

link_file () {
    file=$1

    if [[ ! -f "$dev_path/$file" ]]; then
        if [[ -f "$web_path/$file" ]]; then
            cp $web_path/$file $dev_path/$file
        else
            touch $dev_path/$file
        fi
    fi

    rm -f $web_path/$file
    ln -sf $dev_path/$file $web_path/$file
}

link_directory () {
    dir=$1

    if [[ ! -d "$dev_path/$dir" ]]; then
        if [[ -d "$web_path/$dir" ]]; then
            cp -r $web_path/$dir $dev_path/
        else
            mkdir -p $dev_path/$dir
        fi
    fi

    rm -rf $web_path/$dir
    ln -sf $dev_path/$dir $web_path/$dir
}

mkdir -p $dev_path

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
            if [[ ! -d "$web_path/Packages/$package_type" ]]; then
                mkdir -p "$web_path/Packages/$package_type"
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
