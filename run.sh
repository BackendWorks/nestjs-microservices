#!/bin/sh
echo "---------- Nest Microservices ----------"
echo "Available commands: ["install", "gen", "build", "run"]"
echo "Enter command : "
read command

case $command in
    run)
        cat .env
        up="COMPOSE_FILE=docker-compose.yml"
        for entry in */
        do
            if [ -e $entry/nest-cli.json ]
            then
                unameOut="$(uname -s)"
                if [[ "$unameOut" == "linux"* ]] || [[ "$unameOut" == "darwin"* ]]; then
                    up+=":./$entry/docker-compose.yml"
                    elif [[ "$unameOut" == "win"* ]] || [[ "$unameOut" == "MINGW64_NT"* ]]; then
                    up+=";./$entry/docker-compose.yml"
                fi
            fi
        done
        echo $up >> .env
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
    gen)
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

