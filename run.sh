#!/bin/sh
echo "---------- Nest Microservices ----------"
echo "Available commands: ["install", "generate", "build", "start"]"
echo "Enter command : "
read command

case $command in
    start)
        for entry in */
        do
            if [ -e $entry/nest-cli.json ]
            then
                cp -r .env $entry.development.env    
            fi
        done
        docker-compose up
    ;;
    install)
        for entry in */
        do
            if [ -e $entry/nest-cli.json ]
            then
                echo "Installing node_modules in $entry..."
                cd $entry
                npm install
                cd ..
            fi
        done
    ;;
    generate)
        echo "Enter service name : "; read name
        echo "Generating service files..."
        nest new $name
    ;;
    build)
        for entry in */
        do
            if [ -e $entry/nest-cli.json ]
            then
                echo "Building dist folder in $entry..."
                cd $entry
                npm run build
                cd ..
            fi
        done
    ;;
esac

