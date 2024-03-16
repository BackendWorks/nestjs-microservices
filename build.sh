#!/bin/bash

build_docker_image() {
    local folder="$1"
    if [ -e "$folder/Dockerfile" ]; then
        echo ">>> Building service ${folder%/}..."
        (cd "$folder" && docker build -t "nestjs_${folder%/}:latest" -f Dockerfile . && echo ">>> Build completed") &
    fi
}

export -f build_docker_image

find . -maxdepth 1 -type d -exec bash -c 'build_docker_image "$0"' {} \;
wait

echo ">>> All builds completed"
