#!/bin/sh
for entry in */; do
    if [ -e $entry/Dockerfile ]; then
        cd $entry
        echo "********** Deploying ${entry%/} ************"
        docker build -t nestjs-microservices-${entry%/}:latest -f Dockerfile .
        echo "********** Build completed ************"
        docker tag nestjs-microservices-${entry%/}:latest hmake98/nestjs-microservices-${entry%/}:latest
        echo "********** Build tagged ************"
        docker push hmake98/nestjs-microservices-${entry%/}:latest
        echo "********** Build pushed ************"
        cd ..
    fi
done

