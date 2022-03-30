#!/bin/sh
# remove slash from last echo ${@%/}
for entry in */; do
    if [ -e $entry/nest-cli.json ]; then
        cp -r .env $entry.env
    fi
done
echo "starting docker-compose..."
docker-compose up
