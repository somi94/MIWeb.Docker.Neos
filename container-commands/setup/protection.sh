#!/usr/bin/env bash

cd $BUILD_PATH_BASE

echo "Setting up webserver protection..."
htpasswd_file="$BUILD_PATH_BASE/Web/.htpasswd"
htaccess_file="$BUILD_PATH_BASE/Web/.htaccess"
htaccess_file_tmp="$BUILD_PATH_BASE/Web/_.htaccess"
if [[ -n "$SERVER_PROTECTION_USER" && -n "$SERVER_PROTECTION_PASSWORD" ]]; then
    echo "Creating htpasswd for '$SERVER_PROTECTION_USER'..."
    htpasswd -dbc "$htpasswd_file" "$SERVER_PROTECTION_USER" "$SERVER_PROTECTION_PASSWORD"

    echo "Updating htaccess..."
    if [[ ! -f "$BUILD_PATH_BASE/Web/_.htaccess" ]]; then
        mv "$htaccess_file" "$htaccess_file_tmp"
    fi
    rm -rf "$htaccess_file"
    echo "AuthType Basic" >> "$htaccess_file"
    echo "AuthName \"Authentication required.\"" >> "$htaccess_file"
    echo "AuthUserFile $htpasswd_file" >> "$htaccess_file"
    echo "Require valid-user" >> "$htaccess_file"
    cat "$htaccess_file_tmp" >> "$htaccess_file"
elif [[ -f "$htpasswd_file" ]]; then
    echo "No webserver protection defined, removing old htpasswd..."
    rm -rf "$htpasswd_file"
    echo "Updating htaccess..."
    mv "$htaccess_file_tmp" "$htaccess_file"
else
    echo "No webserver protection defined, skipping htpasswd setup..."
fi