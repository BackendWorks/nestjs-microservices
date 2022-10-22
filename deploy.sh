# to deploy containers to container registry service, first you have to configure aws cli into your system.
# remove slash from last echo ${@%/}
#!/bin/sh
for entry in */; do
    if [ -e $entry/Dockerfile.prod ]; then
        cd $entry
        echo "Deploying ${entry%/} service..."
        docker build -t nestjs-ms:${entry%/} -f Dockerfile.prod .
        docker tag nestjs-ms:${entry%/} 339146391262.dkr.ecr.ap-south-1.amazonaws.com/nestjs-ms:${entry%/}
        docker push 339146391262.dkr.ecr.ap-south-1.amazonaws.com/nestjs-ms:${entry%/}
        cd ..
    fi
done

