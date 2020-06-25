#!/bin/bash

# full server path, e.g. "root@192.168.0.0.1"
server=$1
# the docker image which should be deployed
image=$2
# the path where the docker image can be saved temporarily
tmp_file_name="/tmp/${RANDOM}.tar.gz"

echo "Saving docker image to compressed file ..."
docker save ${image} | gzip > ${tmp_file_name}
echo "Created file '${tmp_file}'"

scp $tmp_file_name ${server}:/tmp
echo "Copied file to server"

rm $tmp_file_name
echo "Deleted local file '${tmp_file_name}'"

ssh $server "
   docker load < ${tmp_file_name}
   rm ${tmp_file_name}
   cd /data/compose
   docker-compose stop -t 5 remembrall
   IMAGE=${image} docker-compose create remembrall
   IMAGE=${image} docker-compose start remembrall
"
echo "Restarted application"

