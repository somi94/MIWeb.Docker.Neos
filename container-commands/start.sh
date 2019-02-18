#!/usr/bin/env bash

neos-utils setup &

#echo "Waiting for system user setup..."
#while [ $(grep -c "^$SYSTEM_USER_NAME:" /etc/passwd) -eq 0 ]; do 
#	sleep 0.1
#done

# run apache
echo "Starting webserver..."
#runuser -l "$SYSTEM_USER_NAME" -c apache2-foreground
apache2-foreground
if [ $? -eq 0 ];then
   echo "Application stopped."
else
   echo "Apache crashed (exit code $?)!"
   exit 1
fi
