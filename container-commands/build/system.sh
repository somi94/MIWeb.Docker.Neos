#!/usr/bin/env bash

# setup users
neos-utils build system-user $SYSTEM_USER_NAME $SYSTEM_USER_ID
if [ $? -ne 0 ]; then
	echo "Adding system user '$SYSTEM_USER_NAME' (id: '$SYSTEM_USER_ID') failed. Aborting..."
    exit 1
fi

neos-utils build system-user $SERVER_USER_NAME $SERVER_USER_ID
if [ $? -ne 0 ]; then
    echo "Adding server user '$SERVER_USER_NAME' (id: '$SERVER_USER_ID') failed. Aborting..."
    exit 1
fi

# setup  keys
if [[ ! -f "$BUILD_PATH_KEYS/id_rsa_deploy" ]]; then
    echo "No deployment key given, generating it..."
    ssh-keygen -q -t rsa -N '' -f "$BUILD_PATH_KEYS/id_rsa_deploy"
fi
echo "Setting up deployment key..."
mkdir "/root/.ssh"
chmod ga-rwx "/root/.ssh"
chmod u+rw "/root/.ssh"
cp "$BUILD_PATH_KEYS/id_rsa_deploy" "/root/.ssh/id_rsa"
chmod ga-rwx "/root/.ssh/id_rsa"
chmod u+rw "/root/.ssh/id_rsa"

# TODO: find a better fix for host key verification issue
echo "Setting up ssh config..."
echo "Host *" >> "/root/.ssh/config"
echo "    StrictHostKeyChecking no" >> "/root/.ssh/config"
chmod ga-rwx "/root/.ssh/config"
chmod u+rw "/root/.ssh/config"

echo "Applying project file permissions (user: '$SYSTEM_USER_NAME', group: '$SERVER_USER_GROUP')..."
chown -R $SYSTEM_USER_NAME:$SERVER_USER_GROUP $BUILD_PATH_DIST

# setup htpasswd
echo "Setting up htpasswd..."
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