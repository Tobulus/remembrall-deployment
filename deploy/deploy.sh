#!/bin/bash
# deploys a tagged docker image to a given server

# full server path, e.g. "root@192.168.0.0.1:/data"
server_path=$1
# the tag of the docker image which should e deployes
docker_tag=$2
# the path where the docker image can be saved temporarily
tmp_file="/tmp/${RANDOM}.tar.gz"

echo "Saving docker image to compressed file ..."
docker save ${docker_tag} | gzip > ${tmp_file}
echo "Created file '${tmp_file}'"

# scp $tmp_file $server_path

rm $tmp_file
echo "Deleted file '${tmp_file}'"

