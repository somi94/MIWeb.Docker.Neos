#!/usr/bin/env bash

cd $BUILD_PATH_BASE

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