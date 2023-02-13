#!/bin/bash

printf "Please select service:\n"
select d in */; do
    test -n "$d" && break
    echo ">>> Invalid Selection"
done
if [ ${d%/} == 'fluent-bit' ]; then
    exit 1
fi
if [ -e $d/Dockerfile ]; then
    echo "Deploying service ${d%/}..."
    cd $d
    echo "Logging into AWS ecr"
    aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-south-1.amazonaws.com/nestjs-microservices-${d%/}
    echo "********** Deploying ${d%/} ************"
    docker build -t nestjs-microservices-${d%/}:latest -f Dockerfile .
    echo "********** Build completed ************"
    docker tag nestjs-microservices-${d%/}:latest <account-id>.dkr.ecr.ap-south-1.amazonaws.com/nestjs-microservices-${d%/}:latest
    echo "********** Build tagged ************"
    docker push <account-id>.dkr.ecr.ap-south-1.amazonaws.com/nestjs-microservices-${d%/}:latest
    echo "********** Build pushed ************"
    cd ..
fi
