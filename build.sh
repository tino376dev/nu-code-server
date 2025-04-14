#! /usr/bin/env bash

# Get the path of the script
folder=$(dirname "$(realpath "$0")")

# loop through and build containers
for dockerfile in $folder/*.Dockerfile; do

    # parse the dockerfile name
    dockerfile=$(basename "$dockerfile")
    image=$(echo "$dockerfile" | cut -d'@' -f1)
    version=$(echo "$dockerfile" | cut -d'@' -f2 | sed 's/.Dockerfile$//')

    # build the image
    tag="code-server-$image:$version"
    podman build --no-cache -t $tag -f $folder/$dockerfile $folder

done
echo $tag
