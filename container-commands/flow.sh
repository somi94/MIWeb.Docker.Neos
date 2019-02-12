#!/usr/bin/env bash

web_path=/var/www/html

cd $web_path
./flow "${@:3}"
