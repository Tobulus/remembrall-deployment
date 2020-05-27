#!/bin/bash

# full server path, e.g. "root@192.168.0.0.1"
server=$1
# the docker image which should be deployed
image=$2
# the path where the docker image can be saved temporarily
tmp_file_name="/tmp/${RANDOM}.tar.gz"

echo "Saving docker image to compressed file ..."
docker save ${image} | gzip > ${tmp_file}
echo "Created file '${tmp_file}'"

scp $tmp_file '${server}/tmp'
echo "Copied file to server"

rm $tmp_file
echo "Deleted local file '${tmp_file_name}'"

ssh $server "
   docker load ${tmp_file_name}
   rm ${tmp_file_name}
   cd /data
   docker-compose down
   IMAGE=${image} docker-compose up
"
echo "Restarted application"

