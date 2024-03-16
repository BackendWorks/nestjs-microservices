#!/bin/bash

printf "Please select service:\n"
select d in */; do
    test -n "$d" && break
    echo ">>> Invalid Selection"
done

service_name="${d%/}"

if [ "$service_name" == 'fluent-bit' ]; then
    exit 1
fi

service_dir="./$service_name"

if [ ! -e "$service_dir/Dockerfile" ]; then
    echo ">>> Dockerfile not found for service $service_name"
    exit 1
fi

echo ">>> Deploying service $service_name..."
cd "$service_dir" || exit

aws_ecr_login() {
    echo ">>> Logging into AWS ECR"
    aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nestjs-microservices-$service_name"
}

build_and_push_image() {
    local image_name="nestjs_$service_name:latest"
    echo ">>> Building $image_name"
    docker build -t "$image_name" -f Dockerfile .
    echo ">>> Tagging $image_name"
    docker tag "$image_name" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nestjs-ms_$service_name:latest"
    echo ">>> Pushing $image_name"
    docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nestjs-ms_$service_name:latest"
}

aws_ecr_login && build_and_push_image

echo ">>> Deployment completed for $service_name"
cd ..
