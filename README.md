# Nest Microservices with RabbitMQ (Basic Version)
Fully managed microservices starter using NestJS, Kong API gateway, RabbitMQ, Redis Queues, Firebase Cloud Notifications.

![Microservice drawio (2)](https://user-images.githubusercontent.com/23061515/160799926-6ea731ae-ff63-4044-9452-b58f3cbe99a3.png)

## Dependencies & Services
- RabbitMQ - https://www.rabbitmq.com/
- Redis - https://redis.io/
- Grafana - https://grafana.com/
- MognoDB - https://www.mongodb.com/
- PostgreSQL - https://www.postgresql.org/
- Kong - https://konghq.com/
- Loki - https://grafana.com/oss/loki/
- Fluent-Bit - https://fluentbit.io/
## Get started
- use `git submodule update --init --recursive` command to update/fetch submodules.
- `AUTO RELOAD` is enabled for docker-compose on file changes using docker volumes. so, If you do any kind of changes in local it will automatically reflect to docker containers.
- Services are included with type-safe interfaces worker, queues(Redis), log drivers.
- To explore APIs collection here is the link of [postman](https://www.getpostman.com/collections/d1dccb090ce55fe39f0a) collection

## Setting up an environment
- Core dependencies such as RabbitMQ, Postgres database, Redis connection, MongoDB services are required to start all services together.
- You can use `docker-compose` to setting up all Core services Or you can install it in your own system one by one.
- Use `example.env` as reference.
- `kong.yml` file will be used for routing of services. after creating new service, define any new services in `kong.yml` first.
- The development server will start on port `8080`. so, base url for server would be `http://localhost:8080`. you can reconfigure this prefix path in `kong.yml`.

## Setup Grafana Dashboard
To see the logs on Grafana dashboard, you can follow YouTube video or below steps.
1. Open the browser and go to http://localhost:3000, use default values admin and admin for username and password.
2. Now, go to http://localhost:3000/datasources and select Loki from Logging and document databases section.
3. Enter http://loki:3100 in URL under HTTP section. We can do this because we are running Loki and Grafana in the same network.
4. loki else you have to enter host IP address and port here, click on Save and Test button from the bottom of the page.
5. Now, go to 3rd tab Explore from the left sidebar or http://localhost:3000/explore

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

## Deployment

Deploy services to dockerhub.
```
sh deploy.sh
```
Notes:
- Also use this script to deploy services to ECR. Do changes in `deploy.sh` script accordingly.
- Use `.prod.env` file for deployment of the services. 
- Deployment can be done in two ways
  - Docker compose context method (Cloud Formation). follow this (Blog)[https://www.docker.com/blog/docker-compose-from-local-to-amazon-ecs/] 
  - Use ECS CLI method. follow this (Blog)[https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html]
## Docker Notes:
- Use `hostname` of service to connect service internally in local docker environment.
- for rebuild all services use command `docker-compose up --build`.  
- Use `docker-compose.prod.yml` for deployment.

## Blogs and References:
- https://www.infracloud.io/blogs/logging-in-kubernetes-efk-vs-plg-stack/
- https://faun.pub/setting-up-centralized-logging-environment-using-efk-stack-with-docker-compose-c96bb3bebf7






