# NestJS Microservices with RabbitMQ / Grafana / Helm Charts
Fully managed Microservices starter pack using **NestJS / RabbitMQ**. created with SQL, NoSQL databases, BullMQ implementation, Kong API Gateway, Grafana Logging stack and Helm charts.

## Dependencies & Services
- RabbitMQ - https://www.rabbitmq.com
- Redis - https://redis.io
- Grafana - https://grafana.com
- MognoDB - https://www.mongodb.com
- PostgreSQL - https://www.postgresql.org
- Kong - https://konghq.com
- Loki - https://grafana.com/oss/loki
- Prisma - https://www.prisma.io
- Helm - https://helm.sh
- Firebase - https://firebase.google.com
- Fluent-Bit - https://grafana.com/docs/loki/latest/clients/fluentbit

## Get started
- use `git submodule update --init --recursive` command to update/fetch submodules.
- use `.env.local` file while working on local environment. 
- use `buildspec.yml` file for AWS codepipeline. 
- `kong.yml` from `kong/conf` file is configured for api gateway. add new services in `kong.yml` file.
- Kong development server endpoint will start on port `8000`. 

## Run in local

start core services (postgres, rabbitmq, mongodb, redis)
```bash
npm start up 
```

Now, go to service folder `cd auth`
```bash
npm run dev
```

to stop core services, run 
```bash
npm run down
```

## Run Local Env in docker-compose 
```bash
docker-compose up 
```
## Docker Notes:
- Use `name` of the service to connect service internally with docker compose environment.
- for rebuild services use command `docker-compose up --build`.  

## Setup Grafana Dashboard in Local Env
To see the logs on Grafana dashboard, follow below steps.
1. Open the browser and go to http://localhost:3000, use default credentials username "admin" and password "admin" to login.
2. Now, go to http://localhost:3000/datasources and select Loki from Logging and document databases section.
3. Enter http://loki:3100 in URL under HTTP section. We can do this because we are running Loki and Grafana in the same network.
4. loki else you have to enter host IP address and port here, click on Save and Test button from the bottom of the page.
5. Now, go to 3rd tab "Explore" from the left sidebar or http://localhost:3000/explore
6. select containers and run the query. you will see below view on your screen.
![image](https://user-images.githubusercontent.com/23061515/217284063-5a548f77-ac0c-42b3-bfdb-963a62f8788a.png)

## Deployment in ECR

```bash
sh deploy.sh
```

Notes:
- change "aws_region" and "aws_account_id" as per your AWS account.

## K8s Deployment with Helm charts:

To start with helm deployment, make sure that you have started Minikube on your local machine.

```bash
minikube start
```
Also, make sure that core services are running on docker containers, as we're using core services as a dependency in helm charts.

Now, install helm charts
```bash
helm install nestjs-microservices helm 
```
To get services endpoints
```bash
minikube service list
```
Clean up
```bash
helm uninstall nestjs-microservices
```