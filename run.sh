#!/bin/sh
for entry in */; do
    if [ -e $entry/nest-cli.json ]; then
        cp -r .env $entry.development.env
    fi
done
docker-compose up
