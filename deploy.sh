#!/bin/sh
echo "Logging into AWS ecr"
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <ECR_URI>
for entry in */; do
    if [ -e $entry/Dockerfile ]; then
        cd $entry
        echo "********** Deploying ${entry%/} ************"
        docker build -t nestjs-microservices-${entry%/}:latest -f Dockerfile .
        echo "********** Build completed ************"
        docker tag nestjs-microservices-${entry%/}:latest <REPO_URI>:latest
        echo "********** Build tagged ************"
        docker push <REPO_URI>:latest
        echo "********** Build pushed ************"
        cd ..
    fi
done

