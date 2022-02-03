# Nest Microservices with RabbitMQ (Basic Version)
Fully managed microservices starter using Kong API gateway, RabbitMQ and Nestjs Framework.

![Screenshot 2021-09-16 at 6 50 37 PM](https://user-images.githubusercontent.com/23061515/133619746-5598d4b6-e5eb-481e-b916-04bf56dce49c.png)


## Get started
- `AUTO RELOAD is enabled for docker-compose on file changes using docker volumes`
- Services included with type-safe interfaces and managed queues using rabbitmq.
- Basic flow is implemented as user, post functionality.
- As a base gateway Kong is being used. you can get more information about Kong from [here](https://docs.konghq.com/).
- To explore apis collection here is the link of [postman](https://www.getpostman.com/collections/d1dccb090ce55fe39f0a) collection
- It's still under development process. so, some feature might not work.
- prettier feature will work out of root. so, install the `node_modules` for root also

## Installation

Install node_modules
```
npm i 
```
run a single service
```
npm start
```
build a single service
```
npm run build
```
run in production
```
npm run prod
```
run in docker
```
docker-compose up -d
```

### CLI commands: 
```
sh run.sh
```
- install: for installation of node_modules in services.
- build: build dist folder for all services.
- gen: generate new service
## Docker Notes:
- If you're using docker environment as your development env, then your need to change `localhost` to `host.docker.internal` for connection of internal connection with docker.
- After adding new service, first add service name and port in `.env` file in root. as it'll use in docker-compose file for specific service.
- Using `docker-compose up -d` the development server will start on port `8080`. so, base url for server would be `http://localhost:8080` and then add the service name after. like `http://localhost:8080/user`
- you need to specify services into root `.env` file. as there are optional services in microservice and you can choose which service should run. check `example.env` file you can found `compose_files` variable.
- `compose_files` will work in different platforms.
  - in `windows` seperator should be `;`
  - in `mac` and `linux` platform seperator should be `:`  
- `docker-compose up -d` command will create application in watch mode.  
  
#### Pending work: 
- add building script and run script using bash.
- add file services, loggers, and common service which will be used as a module.
- add ACL as root service.
- improve eslint functions.
- add admin module.
- oauth authentication.
- deployment scripts.
- add git submodules.
- versioning with release notes.
- use ELK for logger.






