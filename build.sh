#!/bin/bash
for folder in */; do
    if [ -e $folder/Dockerfile ]; then
        echo ">>> Building service ${folder%/}..."
        cd $folder
        docker build -t nestjs-microservices-${folder%/}:latest -f Dockerfile .
        echo ">>> Build completed"
        cd ..
    fi
done
