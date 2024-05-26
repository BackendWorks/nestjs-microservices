#!/bin/bash

aws_ecr_login() {
    echo ">>> Logging into AWS ECR"
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
}

build_and_push_image() {
    local service_name="$1"
    local image_name="nestjs_$service_name:latest"
    local ecr_image_uri="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$service_name:latest"

    echo ">>> Building $image_name"
    docker build -t "$image_name" -f "$service_name/Dockerfile" "$service_name"

    if [ $? -eq 0 ]; then
        echo ">>> Tagging $image_name"
        docker tag "$image_name" "$ecr_image_uri"

        echo ">>> Pushing $image_name"
        docker push "$ecr_image_uri"

        if [ $? -eq 0 ]; then
            echo ">>> Deployment completed for $service_name"
        else
            echo ">>> Failed to push image $image_name" >&2
        fi
    else
        echo ">>> Failed to build image $image_name" >&2
    fi
}

printf "Please select service:\n"
select d in */; do
    test -n "$d" && break
    echo ">>> Invalid Selection"
done

service_name="${d%/}"

if [ "$service_name" == 'fluent-bit' ]; then
    echo ">>> Service fluent-bit is not allowed for deployment"
    exit 1
fi

if [ ! -e "$service_name/Dockerfile" ]; then
    echo ">>> Dockerfile not found for service $service_name"
    exit 1
fi

echo ">>> Deploying service $service_name..."
aws_ecr_login && build_and_push_image "$service_name"
