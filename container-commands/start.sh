#!/usr/bin/env bash

neos-utils setup &

# run apache
echo ""
echo "################################"
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
