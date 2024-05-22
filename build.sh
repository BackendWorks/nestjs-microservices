#!/bin/bash

# Function to build a Docker image for a given folder
build_docker_image() {
    local folder="$1"
    local service_name=$(basename "$folder")
    if [[ -e "$folder/Dockerfile" ]]; then
        echo ">>> Building service ${service_name}..."
        if docker build -t "${service_name}:latest" -f "$folder/Dockerfile" "$folder"; then
            echo ">>> Build completed for ${service_name}"
        else
            echo ">>> Build failed for ${service_name}" >&2
        fi
    fi
}

# Export the function to be used by parallel
export -f build_docker_image

# Find all directories with a Dockerfile and build images in parallel
find . -maxdepth 1 -type d -not -path '.' -print0 | xargs -0 -n 1 -P $(nproc) bash -c 'build_docker_image "$0"'

echo ">>> All builds completed"
