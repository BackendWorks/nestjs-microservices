#!/bin/bash

build_docker_image() {
    local folder="$1"
    local service_name=$(basename "$folder")
    if [[ -e "$folder/Dockerfile" ]]; then
        echo ">>> Building service ${service_name}..."
        docker build -t "${service_name}:latest" -f "$folder/Dockerfile" "$folder" && echo ">>> Build completed for ${service_name}"
        echo ">>> Built ${service_name}..."
    fi
}

find . -maxdepth 1 -type d | while read -r dir; do
    if [[ "$dir" != "." ]]; then
        build_docker_image "$dir"
    fi
done

echo ">>> All builds completed"
