#!/bin/bash

# Function to log in to AWS ECR
aws_ecr_login() {
    echo ">>> Logging into AWS ECR"
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
    if [ $? -ne 0 ]; then
        echo ">>> AWS ECR login failed" >&2
        exit 1
    fi
}

# Function to build and push the Docker image
build_and_push_image() {
    local service_name="$1"
    local image_name="nestjs_${service_name}:latest"
    local ecr_image_uri="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${service_name}:latest"

    echo ">>> Building ${image_name}"
    docker build -t "$image_name" -f "${service_name}/ci/Dockerfile" "$service_name"
    if [ $? -ne 0 ]; then
        echo ">>> Failed to build image ${image_name}" >&2
        exit 1
    fi

    echo ">>> Tagging ${image_name}"
    docker tag "$image_name" "$ecr_image_uri"

    echo ">>> Pushing ${image_name}"
    docker push "$ecr_image_uri"
    if [ $? -ne 0 ]; then
        echo ">>> Failed to push image ${image_name}" >&2
        exit 1
    fi

    echo ">>> Deployment completed for ${service_name}"
}

# Prompt the user to select a service
printf "Please select a service:\n"
select d in */; do
    test -n "$d" && break
    echo ">>> Invalid Selection"
done

service_name="${d%/}"

# Check if the selected service is 'fluent-bit'
if [ "$service_name" == 'fluent-bit' ]; then
    echo ">>> Service fluent-bit is not allowed for deployment"
    exit 1
fi

# Check if Dockerfile exists for the selected service
if [ ! -e "${service_name}/Dockerfile" ]; then
    echo ">>> Dockerfile not found for service ${service_name}" >&2
    exit 1
fi

echo ">>> Deploying service ${service_name}..."
aws_ecr_login && build_and_push_image "$service_name"
