#!/bin/sh
for entry in */; do
    if [ -e $entry/nest-cli.json ]; then
        echo "Building Service $entry..."
        cd $entry
        npm run build
        cd ..
    fi
done
