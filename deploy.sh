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
    echo ">>> Deploying service ${d%/}..."
    cd $d
    echo ">>> Logging into AWS ecr"
    aws ecr get-login-password --region <aws_region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/nestjs-microservices-${d%/}
    echo ">>> Deploying ${d%/}"
    docker build -t nestjs-ms_${d%/}:latest -f Dockerfile .
    echo ">>> Build completed"
    docker tag nestjs-ms_${d%/}:latest <aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/nestjs-ms_${d%/}:latest
    echo ">>> Build tagged"
    docker push <aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/nestjs-ms_${d%/}:latest
    echo ">>> Build pushed"
    cd ..
fi
