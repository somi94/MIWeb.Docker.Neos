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

	if [[ -f "$dev_path/$file" ]]; then
    	rm -f $base_path/$file
    	ln -sf $dev_path/$file $base_path/$file
	fi
}

link_directory () {
    dir=$1
    dev_dir=$dir
    if [[ -n "$2" ]]; then
        dev_dir="$2"
    fi

    if [[ ! -d "$dev_path/$dev_dir" ]]; then
        if [[ -d "$base_path/$dir" ]]; then
            cp -r $base_path/$dir $dev_path/$dev_dir
        else
            mkdir -p $dev_path/$dev_dir
        fi
    fi

    if [[ -d "$dev_path/$dev_dir" ]]; then
		rm -rf $base_path/$dir
		ln -sf $dev_path/$dev_dir $base_path/$dir
    fi
}

mkdir -p $dev_path
find $base_path -type l -delete

if [[ -d "$dev_path" ]]; then
    echo "Linking dev files from $dev_path..."
    link_file composer.json
    #link_file composer.lock
    link_directory Configuration

    link_directory DistributionPackages Packages
#    if [[ -d "$dev_path/Packages" ]]; then
#        echo "Linking dev packages..."
#        for package_type_dir in $dev_path/Packages/*; do
#            package_type=$(basename "$package_type_dir")
#            echo "Linking dev packages of type '$package_type'..."
#
#            if [[ ! -d "$base_path/Packages/$package_type" ]]; then
#                mkdir -p "$base_path/Packages/$package_type"
#            fi
#
#            for package_dir in $package_type_dir/*; do
#                package=$(basename "$package_dir")
#                package_path="Packages/$package_type/$package"
#                echo "Linking dev package '$package_path'..."
#                link_directory $package_path
#            done
#        done
#    fi
else
    echo "No dev files to link."
fi
