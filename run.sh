#!/bin/sh
echo "---------- Nest Microservices ----------"
echo "Available commands: ["install", "generate", "build", "run"]"
echo "Enter command : "
read command

case $command in
    run)
        for entry in */
        do
            if [ -e $entry/nest-cli.json ]
            then
                cd $entry
                pm2 start npm --name "$entry" -- start
                cd .. 
            fi
        done
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
        echo "Would you to add this service in kong routes? [Y/n] "; read ans
        echo "Enter port for $name service : "; read port
        if [ "$ans" = 'Y' ]; then
            echo "  - name: $name
    url: http://host.docker.internal:$port
    routes:
      - name: $name
        paths:
            - /$name" >> kong.yml
        fi
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

