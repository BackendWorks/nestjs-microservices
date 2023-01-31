# Nest Microservices with RabbitMQ (Basic Version)
Fully managed microservices starter using NestJS, Kong API gateway, RabbitMQ, Redis Queues, Firebase Cloud Notifications.

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
- copy env variables from each submodule repo from `example.env` file. 
- To explore APIs collection here is the link of [postman](https://www.getpostman.com/collections/d1dccb090ce55fe39f0a) collection

## Setting up an environment notes:
- you can start local environment by running `docker-compose.core.yml` file. file only contains service dependencies so that you don't need to start each service seperatly on your own. but keep in mind that if you're running any of the service in local then you need to change `.env` and replace all docker host variables to `localhost`. otherwise services will not work for local machine. 
- you can start all services together using `docker-compose up`. keep in mind that you will have to change environment variables to docker host variables as we're running all the services in docker and docker can't find local network in the container.
- `kong.yml` file will be used for routing of services. after creating new service, define that service in `kong.yml` first.
- The development server will start on port `8000`. 

## Setup Grafana Dashboard
To see the logs on Grafana dashboard, you can follow YouTube video or below steps.
1. Open the browser and go to http://localhost:3000, use default values admin and admin for username and password.
2. Now, go to http://localhost:3000/datasources and select Loki from Logging and document databases section.
3. Enter http://loki:3100 in URL under HTTP section. We can do this because we are running Loki and Grafana in the same network.
4. loki else you have to enter host IP address and port here, click on Save and Test button from the bottom of the page.
5. Now, go to 3rd tab Explore from the left sidebar or http://localhost:3000/explore

## Run in local

1. first start all deps from `docker-compose.test.yml`
```
docker-compose -f docker-compose.test.yml up 
```

2. to start any service in development mode
```
npm start
```

3. then you can access service endpoint directly using localhost.

## Run in docker 

1. build docker-compose images 
```
docker-compose up 
```
2. and then you can access services from kong api gateway on port `8000`. 

## Deployment

Deploy services to dockerhub.
```
sh deploy.sh
```
Notes:
- you can also use this script to deploy services to ECR. change `deploy.sh` script accordingly. 
- you can follow deployment process as below
  - Docker compose context method (Cloud Formation with compose CLI). follow this (Blog)[https://www.docker.com/blog/docker-compose-from-local-to-amazon-ecs/] 
  - Use ECS CLI method. follow this (Blog)[https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html]
## Docker Notes:
- Use `name` of the service to connect service internally with docker environment.
- for rebuild services use command `docker-compose up --build`.  

## Blogs and References:
- https://www.infracloud.io/blogs/logging-in-kubernetes-efk-vs-plg-stack/
- https://faun.pub/setting-up-centralized-logging-environment-using-efk-stack-with-docker-compose-c96bb3bebf7
