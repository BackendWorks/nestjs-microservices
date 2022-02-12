# Nest Microservices with RabbitMQ (Basic Version)
Fully managed microservices starter using NestJS, Kong API gateway, RabbitMQ, Redis Queues, Firebase Cloud Notifications.

![Screenshot 2021-09-16 at 6 50 37 PM](https://user-images.githubusercontent.com/23061515/133619746-5598d4b6-e5eb-481e-b916-04bf56dce49c.png)


## Dependencies
- RabbitMQ - https://www.rabbitmq.com/
- Redis - https://redis.io/
- Elasticsearch, Logstash, Kibana, Filebeat - https://www.elastic.co/
- MognoDB - https://www.mongodb.com/
- PostgreSQL - https://www.postgresql.org/
- Kong - https://konghq.com/

## Get started
- `AUTO RELOAD` is enabled for docker-compose on file changes using docker volumes. so, If you do any kind of changes in local it will automatically reflect to docker containers.
- Services included with type-safe interfaces and managed worker queues using Redis.
- Basic flow is implemented as user, post functionality.
- As a base gateway Kong is being used. you can get more information about Kong from.
- To explore APIs collection here is the link of [postman](https://www.getpostman.com/collections/d1dccb090ce55fe39f0a) collection
- ELK version - `7.5.1`

## Setting up an environment
- Core dependencies such as RabbitMQ, Postgres database, Redis connection, MongoDB for particular services are required to start all services together.
- You can use `docker-compose` to setting up all Core services Or you can install it in your own system one by one.
- Use `example.env` as reference.
- `kong.yml` file will be used for routing of services. so, define any new service in `kong.yml` first.

## Installation

Install dependencies for root.
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
Docker compose run
```
docker-compose up -d
```

### CLI commands: 
```
sh run.sh
```
- `start`: will copy root `.env` file to services as `.development.env` and then start docker-compose
- `install`: for installation of node_modules in services.
- `build`: build dist folder for all services.
- `generate`: generate new service
## Docker Notes:
- If you're using docker environment as your development env, then your need to change `localhost` to `host.docker.internal` for connection of internal connection with docker.
- After adding new service, first add service name and port in `.env` file in root. as it'll use in docker-compose file for specific service.
- Using `docker-compose up -d` the development server will start on port `8080`. so, base url for server would be `http://localhost:8080` and then add the service name after. like `http://localhost:8080/user`. you can configure this prefix path in `kong.yml`
- `docker-compose up -d` command will create application in watch mode.  

#### Pending work: 
- deployment, production level changes






