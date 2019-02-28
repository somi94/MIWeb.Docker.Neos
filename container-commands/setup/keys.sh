#!/usr/bin/env bash

cd $BUILD_PATH_BASE

# setup  keys
#if [[ ! -f "$BUILD_PATH_KEYS/id_rsa_deploy" ]]; then
#    echo "No deployment key given, generating it..."
#    ssh-keygen -q -t rsa -N '' -f "$BUILD_PATH_KEYS/id_rsa_deploy"
#fi
#echo "Setting up deployment key..."
#mkdir "/root/.ssh"
#chmod ga-rwx "/root/.ssh"
#chmod u+rw "/root/.ssh"
#cp "$BUILD_PATH_KEYS/id_rsa_deploy" "/root/.ssh/id_rsa"
#chmod ga-rwx "/root/.ssh/id_rsa"
#chmod u+rw "/root/.ssh/id_rsa"

key=""
if [[ -n "$KEY_DEPLOYMENT" ]]; then
    key="$KEY_DEPLOYMENT"
fi

if [[ -n "$key" ]]; then
    echo "Writing deployment key..."

    mkdir "/root/.ssh"
    chmod ga-rwx "/root/.ssh"
    chmod u+rw "/root/.ssh"

    echo "$key" >> "/root/.ssh/id_rsa"
    chmod ga-rwx "/root/.ssh/id_rsa"
    chmod u+rw "/root/.ssh/id_rsa"
else
    echo "No deployment key given, skipping key creation..."
fi