#!/bin/sh
for entry in */; do
    if [ -e $entry/nest-cli.json ]; then
        echo "Installing `node_modules` in $entry..."
        cd $entry
        npm install
        cd ..
    fi
done
