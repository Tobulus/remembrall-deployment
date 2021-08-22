#!/bin/bash

# full server path, e.g. "root@192.168.0.0.1"
server=$1

# get a list of all available docker images from which the user needs to choose
IMAGES=$(docker images | tail -n +2 | awk '{out=$1":"$2; print out;}')

# select the docker image which should be deployed
select IMAGE in $IMAGES
do
    echo "Selected '$IMAGE' for deployment."
    read -p "Are you sure? " -n 1 -r
    echo    # (optional) move to a new line

    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit
    fi

    # the path where the docker image can be saved temporarily
    tmp_file_name="/tmp/${RANDOM}.tar.gz"

    echo "Saving docker image to compressed file ..."
    docker save ${IMAGE} | gzip > ${tmp_file_name}
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
    break;
done


