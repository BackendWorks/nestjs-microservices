#!/bin/sh
for entry in */; do
    if [ -e $entry/Dockerfile.prod ]; then
        cd $entry
        echo "********** Deploying ${entry%/} ************"
        docker build -t nestjs-:${entry%/} -f Dockerfile.prod .
        echo "********** Build completed ************"
        docker tag nestjs-:${entry%/} 339146391262.dkr.ecr.ap-south-1.amazonaws.com/nestjs-:${entry%/}
        echo "********** Build tagged ************"
        docker push 339146391262.dkr.ecr.ap-south-1.amazonaws.com/nestjs-:${entry%/}
        echo "********** Build pushed ************"
        cd ..
    fi
done

