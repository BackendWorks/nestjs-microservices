# NestJS Microservices with RabbitMQ / Grafana / Helm Charts

Fully managed Microservices starter pack using NestJS / RabbitMQ with SQL and NoSQL databases, Kong API Gateway, Grafana Logging stack, and Helm charts.

For Linux, consider using this tool for Docker container inspection: Lazydocker.
https://github.com/jesseduffield/lazydocker

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

- MOST IMPORTANT: for prisma error regarding mongodb transaction [link](https://github.com/prisma/prisma/issues/8266), to workaround exec this in mongodb docker container using `mongosh` and run `rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}]});`
- Use `git submodule update --init --recursive` command to update/fetch submodules.
- Use `.env.local` file while working on local environment, use `.env.docker` for docker compose environment and use `.env` for production.
- `kong.yml` from `kong/conf/kong.yml` file is configured for api gateway.
- Kong development server endpoint will start on port `8000`.
- Health endpoint: `host:port/api/health`
- Swagger docs endpoint: `host:port/api/docs`

## Run in local

Start core services first (Postgres, RabbitMQ, MongoDB, Redis):

```bash
yarn local:up
```

Now go to the service folder:

```bash
yarn dev
```

To stop core services, run:

```bash
yarn local:down
```

Run All Services in Local with Docker Compose
```bash
sh scripts/start.sh
```

Stop All Services in Local with Docker Compose
```bash
sh scripts/stop.sh
```

To run grafana stack in local docker compose

```bash
# up
yarn grafana:up

# down
yarn grafana:down
```

Note: To attach Fluent Bit container with the service container, ensure logging configuration is enabled in docker-compose.yml file.

## Setup Grafana Dashboard in Local Environment

To see logs on the Grafana dashboard, follow these steps:

1. Open the browser and go to http://localhost:3000. Use default credentials: username "admin" and password "admin".

2. Go to http://localhost:3000/datasources and select Loki from the Logging and Document Databases section.

3. Enter http://loki:3100 in the URL under the HTTP section. This works because Loki and Grafana are running in the same network. Otherwise, use the host IP address and port.

4. Click the "Save and Test" button at the bottom of the page.

5. Go to the 3rd tab "Explore" from the left sidebar or http://localhost:3000/explore.

6. Select containers and run the query. You will see a view similar to this:
   ![image](https://user-images.githubusercontent.com/23061515/217284063-5a548f77-ac0c-42b3-bfdb-963a62f8788a.png)

## Deployment in ECR

```bash
sh scripts/deploy.sh
```

Notes:

- Change "aws_region" and "aws_account_id" as per your AWS account.

## K8s Deployment with Helm charts:

Note: I recommend the tool [k9s](https://k9scli.io/) for better understanding of a cluster. To start with Helm deployment on a local machine, ensure that Minikube is started. Service images should be available in your local Docker environment, and core services should be up and running in the local environment.

If you're unable to use local images in Minikube cluster, refer to this
 [blog](https://medium.com/bb-tutorials-and-thoughts/how-to-use-own-local-doker-images-with-minikube-2c1ed0b0968)

```bash
minikube start
```

Now, install helm charts

```bash
helm install backendworks helm
```

To get services endpoints:
```bash
minikube service list
```
Check Loki stack installed in the current namespace:

```bash
helm list
```
Get Loki IP from the K8s cluster:
```
kubectl get service backendworks-loki
```
Use this ClusterIP to add the datasource Loki in the Grafana dashboard.

```
minikube service list
```

Clean up the local environment:

```bash
helm uninstall backendworks
```
