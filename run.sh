#!/bin/sh
echo "setting up server for env: $NODE_ENV"
for entry in */; do
    if [ -e $entry/nest-cli.json ]; then
        cp -r .env $entry.$NODE_ENV.env
    fi
done

if [ "$NODE_ENV" = "development" ]; then
echo "starting docker-compose with file - docker-compose.dev.yml"
    docker-compose -f docker-compose.dev.yml up
fi

if [ "$NODE_ENV" = "production" ]; then
echo "starting docker-compose with file - docker-compose.prod.yml"
    docker-compose -f docker-compose.prod.yml up
fi
