# NestJS Microservices with RabbitMQ / Grafana / Helm Charts
Fully managed Microservices starter pack using **NestJS / RabbitMQ**. created with SQL, NoSQL databases, Kong API Gateway, Grafana Logging stack and Helm charts.

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

## Get started Notes:
- Use `git submodule update --init --recursive` command to update/fetch submodules.
- Use `.env.local` file while working on local environment and use `.env` for production.
- Make sure to change **service name** to **localhost** in `.env.local` while running single service only in terminal.  
- `kong.yml` from `kong/conf/kong.yml` file is configured for api gateway.
- Kong development server endpoint will start on port `8000`. 
- Health endpoint: `host:port/api/health`
- Swagger docs endpoint: `host:port/api/docs`

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

NOTE: I would recommend tool [k9s](https://k9scli.io/) for better understanding of cluster.

```bash
minikube start
```
Also, make sure that core services are running on docker containers, as we're using core services as a dependency in helm charts.

Now, install helm charts
```bash
helm install nestjs-ms helm 
```
To get services endpoints
```bash
minikube service list
```
Install fluent-bit, loki stack 
```bash
# install grafana repo
helm repo add grafana https://grafana.github.io/helm-charts

# install loki stack chart with fluent-bit
helm upgrade --install loki-stack grafana/loki-stack \
    --set fluent-bit.enabled=true,promtail.enabled=false \
    --namespace=default

# check loki stack installed in current namespace
helm list
# NAME     	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART           	APP VERSION
# loki     	default  	1       	2023-02-27 19:10:51.925923794 +0530 IST	deployed	loki-stack-2.9.9	v2.6.1     
# nestjs-ms	default  	1       	2023-02-27 19:11:14.537649934 +0530 IST	deployed	nestjs-ms-0.1.0 	1.0.0  

# now get loki IP from k8s cluster
kubectl get service loki
# NAME   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
# loki   ClusterIP   10.107.243.160   <none>        3100/TCP   10m
# use this ClusterIP to add datasource Loki in grafana dashboard


# at the end minikube service list will look like this
# |----------------------|-----------------------------------|--------------------|---------------------------|
# |      NAMESPACE       |               NAME                |    TARGET PORT     |            URL            |
# |----------------------|-----------------------------------|--------------------|---------------------------|
# | default              | auth-service                      | No node port       |
# | default              | files-service                     | No node port       |
# | default              | kubernetes                        | No node port       |
# | default              | loki                              | No node port       |
# | default              | loki-headless                     | No node port       |
# | default              | loki-memberlist                   | No node port       |
# | default              | nestjs-ms-grafana                 | service/80         | http://192.168.49.2:30353 |
# | default              | nestjs-ms-kong-proxy              | kong-proxy/80      | http://192.168.49.2:31208 |
# |                      |                                   | kong-proxy-tls/443 | http://192.168.49.2:31070 |
# | default              | nestjs-ms-kong-validation-webhook | No node port       |
# | default              | notification-service              | No node port       |
# | default              | post-service                      | No node port       |
# | kube-system          | kube-dns                          | No node port       |
# | kube-system          | metrics-server                    | No node port       |
# | kubernetes-dashboard | dashboard-metrics-scraper         | No node port       |
# | kubernetes-dashboard | kubernetes-dashboard              | No node port       |
# |----------------------|-----------------------------------|--------------------|---------------------------|
# To access grafana : http://192.168.49.2:30353
# To access kong gateway: http://192.168.49.2:31208
```
Clean up
```bash
helm uninstall nestjs-ms
helm uninstall loki
```
