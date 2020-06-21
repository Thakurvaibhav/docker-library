#!/usr/bin/env sh
set -e

/opt/halyard/bin/halyard &

#Wait for Halyard to start
while ! nc -z localhost 8064; do    
    sleep 1
done
echo "####### HAL IS RUNNING ############"

#Create backup and upload the latest to s3
echo "Starting hal backup"
cd /root
hal backup create --daemon-endpoint http://halyard:8064
PATH=${AWS_BCUKET}/hal_backup
KEY=`ls -t *.tar | head -1`
aws s3 cp ${KEY} ${PATH}

#Delete backup older than 2 days
find . -type f -mtime +2 -name '*.tar' -execdir rm -- '{}' \;
