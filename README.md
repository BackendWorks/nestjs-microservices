# Nest Microservices with RabbitMQ (Basic Version)
Fully managed microservices starter using NestJS, Kong API gateway, RabbitMQ, Redis Queues, Firebase Cloud Notifications.

![Microservice drawio (2)](https://user-images.githubusercontent.com/23061515/160799926-6ea731ae-ff63-4044-9452-b58f3cbe99a3.png)

## Dependencies
- RabbitMQ - https://www.rabbitmq.com/
- Redis - https://redis.io/
- Elasticsearch, Logstash, Kibana, Filebeat - https://www.elastic.co/
- MognoDB - https://www.mongodb.com/
- PostgreSQL - https://www.postgresql.org/
- Kong - https://konghq.com/

## Get started
- `AUTO RELOAD` is enabled for docker-compose on file changes using docker volumes. so, If you do any kind of changes in local it will automatically reflect to docker containers.
- Services included with type-safe interfaces and managed worker, queues using Redis.
- As a base gateway Kong is being used. you can get more information about Kong from.
- To explore APIs collection here is the link of [postman](https://www.getpostman.com/collections/d1dccb090ce55fe39f0a) collection
- Logger services is implemented using ELK stack with Filebeat.

## Setting up an environment
- Core dependencies such as RabbitMQ, Postgres database, Redis connection, MongoDB for particular services are required to start all services together.
- You can use `docker-compose` to setting up all Core services Or you can install it in your own system one by one.
- Use `example.env` as reference.
- `kong.yml` file will be used for routing of services. so, define new service in `kong.yml` first.

## Installation

Install dependencies for root.
```
npm install
```

Install service deps
```
npm run service-install
```

## Build

Build services
```
npm run build
```

## Run

Start services in development mode
```
npm start
```
start services in production mode
```
npm run prod
```

## Run docker-compose file with build

Build docker-compose images 
```
docker-compose up --build
```

## Clean build folders

Clean build folders in services
```
npm run clean
```
## Docker Notes:
- If you're running docker-compose in windows platform, the URI host should change `localhost` to `host.docker.internal` for connection of internal connection with docker.
- If you're running docker-compose in ubuntu or macOS, the URI should be host name like for `postgres` database it's `database`.
- The development server will start on port `8080`. so, base url for server would be `http://localhost:8080`. you can reconfigure this prefix path in `kong.yml`.
- for rebuild all services use command `docker-compose up --build`.  

#### Pending work: 
- deployment, production level changes






