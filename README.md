# Nest Microservices with RabbitMQ (Version 2)
Fully managed microservices starter using NestJS, Kong API gateway, RabbitMQ, Bull Queues using Redis, Firebase Cloud Notifications, Grafana stack, Fluent-Bit, MongoDB, PostgreSQL, Prisma.

## Dependencies & Services
- RabbitMQ - https://www.rabbitmq.com/
- Redis - https://redis.io/
- Grafana - https://grafana.com/
- MognoDB - https://www.mongodb.com/
- PostgreSQL - https://www.postgresql.org/
- Kong - https://konghq.com/
- Loki - https://grafana.com/oss/loki/
- Fluent-Bit - https://fluentbit.io/
- Prisma - https://www.prisma.io/

## Get started
- use `git submodule update --init --recursive` command to update/fetch submodules.
- copy env variables from each submodule repo from `example.env` file. 
- To explore APIs collection here is the link of [postman](https://www.getpostman.com/collections/d1dccb090ce55fe39f0a) collection
- For CI/CD with AWS CodePipeline, use `buildspec.yml` file.  

## Setting up an environment notes:
- before starting `docker-compose up`, make sure that you have set up `.env` and `.env.dev` file.
- use of `.env` file - to interact with the services using `localhost` by running `docker-compose.core.yml` services in docker. as we're interacting with them in localhost env.
- use of `.env.dev` file - to use environment variables in `docker-compose.yml` file, while running all services together. as we're running those services in docker env.
- `kong.yml` from `kong/conf` file will be used for routing for the services. add new services in `kong.yml` file.
- authentication for each service is handled by kong api gateway itself. to assign authentication, attach jwt plugin in specific service. see kong.yml for example.
- The development server endpoint will start on kong port `8000`. 

## Run in local

1. start core services (postgres, rabbitmq, mongodb, redis)
```
npm start core:up 
```

2. go to service folder `cd auth`, and to start in development mode
```
npm run dev
```

to stop core services, run script
```
npm run core:down
```

## Run in docker-compose 
```
docker-compose up 
```

## Setup Grafana Dashboard
To see the logs on Grafana dashboard, follow below steps.
1. Open the browser and go to http://localhost:3000, use default values admin and admin for username and password.
2. Now, go to http://localhost:3000/datasources and select Loki from Logging and document databases section.
3. Enter http://loki:3100 in URL under HTTP section. We can do this because we are running Loki and Grafana in the same network.
4. loki else you have to enter host IP address and port here, click on Save and Test button from the bottom of the page.
5. Now, go to 3rd tab Explore from the left sidebar or http://localhost:3000/explore
![image](https://user-images.githubusercontent.com/23061515/217284063-5a548f77-ac0c-42b3-bfdb-963a62f8788a.png)

## Deployment

Deploy service to ECR.
```
sh deploy.sh
```

Notes:
- you can also use this script to deploy services to ECR. change `deploy.sh` script accordingly. 
- you can follow deployment process as below
  - Docker compose context method (Cloud Formation with compose CLI). follow this (Blog)[https://www.docker.com/blog/docker-compose-from-local-to-amazon-ecs/] 
  - Use ECS CLI method. follow this (Blog)[https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-cli-tutorial-fargate.html]
## Docker Notes:
- Use `name` of the service to connect service internally with docker compose environment.
- for rebuild services use command `docker-compose up --build`.  

## Blogs and References:
- https://www.infracloud.io/blogs/logging-in-kubernetes-efk-vs-plg-stack/
- https://faun.pub/setting-up-centralized-logging-environment-using-efk-stack-with-docker-compose-c96bb3bebf7
