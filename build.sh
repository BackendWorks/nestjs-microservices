#!/bin/bash

build_docker_image() {
    local folder="$1"
    local service_name="nestjs-microservices-$(basename "$folder")"
    if [[ -e "$folder/Dockerfile" ]]; then
        echo ">>> Building service ${service_name}..."
        if docker build -t "${service_name}:latest" -f "$folder/Dockerfile" "$folder"; then
            echo ">>> Build completed for ${service_name}"
        else
            echo ">>> Build failed for ${service_name}" >&2
        fi
    fi
}

for dir in */; do
    if [[ -e "${dir}/Dockerfile" ]]; then
        build_docker_image "$dir"
    fi
done

echo ">>> All builds completed"
