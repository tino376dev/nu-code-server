#! /usr/bin/env bash

# Get the path of the script
script=$(realpath "$0")
folder=$(dirname "$(dirname "$script")")/containers
container=$folder/$(basename "$script" | sed -n 's/^build-\(.*\)\.sh$/\1/p').Containerfile
name=$(basename "$container" | sed 's/.Containerfile$//')
image=$(echo "$name" | cut -d'@' -f1)
version=$(echo "$name" | cut -d'@' -f2)
tag="code-server-$image:$version"
podman build --no-cache -t $tag -f $container $folder
echo $tag
