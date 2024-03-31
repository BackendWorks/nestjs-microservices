# NestJS Microservices with RabbitMQ / Grafana / Helm Charts

Fully managed Microservices starter pack using **NestJS / RabbitMQ**. created with SQL, NoSQL databases, Kong API Gateway, Grafana Logging stack and Helm charts.

For Linux, I would recommend this tool for docker container inspection: https://github.com/jesseduffield/lazydocker

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
- Fluent-Bit - https://grafana.com/docs/loki/latest/clients/fluentbit

## Get started Notes:

- Use `git submodule update --init --recursive` command to update/fetch submodules.
- Use `.env.local` file while working on local environment, use `.env.docker` for docker compose environment and use `.env` for production.
- `kong.yml` from `kong/conf/kong.yml` file is configured for api gateway.
- Kong development server endpoint will start on port `8000`.
- Health endpoint: `host:port/api/health`
- Swagger docs endpoint: `host:port/api/docs`

## Run in local

Start core services first (postgres, rabbitmq, mongodb, redis)

```bash
yarn dep:up
```

Now go to service folder

```bash
yarn dev
```

To stop core services, run

```bash
yarn dep:down
```

## Run all services in local with docker-compose

```bash
docker compose up
docker compose down
```

To run grafana stack in local

```bash
yarn grafana:up
yarn grafana:down
```

Note: to attach fluent bit container with service container make sure that you enable logging configuration in docker-compose.yml file.

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

## Build in Local

```bash
sh build.sh
```

## K8s Deployment with Helm charts:

NOTE: I would recommend tool [k9s](https://k9scli.io/) for better understanding of a cluster. To start with helm deployment in local machine, make sure that you have started Minikube. service images should be available in your local docker env and core service should be up and running in local env.

If you're unable to use local images in minikube cluster then refer this [blog](https://medium.com/bb-tutorials-and-thoughts/how-to-use-own-local-doker-images-with-minikube-2c1ed0b0968)

```bash
minikube start
```

Now, install helm charts

```bash
helm install nestjs-ms helm
```

To get services endpoints

```bash
minikube service list
```

```bash
# check loki stack installed in current namespace
helm list
# NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART           	APP VERSION
# nestjs-ms	default  	1       	2023-02-27 19:11:14.537649934 +0530 IST	deployed	nestjs-ms-0.1.0 	1.0.0

# now get loki IP from k8s cluster
kubectl get service nestjs-ms-loki
# NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
# nestjs-ms-loki   ClusterIP   10.102.161.158   <none>        3100/TCP   28m

# use this ClusterIP to add datasource Loki in grafana dashboard

# at the end minikube service list will look like this
minikube service list
# |-------------|-----------------------------------|--------------------|---------------------------|
# |  NAMESPACE  |               NAME                |    TARGET PORT     |            URL            |
# |-------------|-----------------------------------|--------------------|---------------------------|
# | default     | auth-service                      | No node port       |                           |
# | default     | files-service                     | No node port       |                           |
# | default     | kubernetes                        | No node port       |                           |
# | default     | nestjs-ms-grafana                 | service/80         | http://192.168.49.2:31679 |
# | default     | nestjs-ms-kong-proxy              | kong-proxy/80      | http://192.168.49.2:32083 |
# |             |                                   | kong-proxy-tls/443 | http://192.168.49.2:31251 |
# | default     | nestjs-ms-kong-validation-webhook | No node port       |                           |
# | default     | nestjs-ms-loki                    | No node port       |                           |
# | default     | nestjs-ms-loki-headless           | No node port       |                           |
# | default     | nestjs-ms-loki-memberlist         | No node port       |                           |
# | default     | notification-service              | No node port       |                           |
# | default     | post-service                      | No node port       |                           |
# | kube-system | kube-dns                          | No node port       |                           |
# |-------------|-----------------------------------|--------------------|---------------------------|
# To access grafana : http://192.168.49.2:30353
# To access kong gateway: http://192.168.49.2:31208
```

Clean up the local env

```bash
helm uninstall nestjs-ms
```
