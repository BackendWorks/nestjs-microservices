# NestJS Microservices with Kafka / Grafana / Kong

A fully managed microservices starter pack using NestJS and Kafka with SQL databases, Kong API Gateway, and the Grafana logging stack.

For Linux, consider using [Lazydocker](https://github.com/jesseduffield/lazydocker) for Docker container inspection.

---

## Dependencies & Services
- **Kafka** - [Apache Kafka](https://kafka.apache.org)
- **Redis** - [Redis](https://redis.io)
- **Grafana** - [Grafana](https://grafana.com)
- **PostgreSQL** - [PostgreSQL](https://www.postgresql.org)
- **Kong API Gateway** - [Kong](https://konghq.com)
- **Loki** - [Grafana Loki](https://grafana.com/oss/loki)
- **Prisma** - [Prisma ORM](https://www.prisma.io)
- **Fluent-Bit** - [Fluent Bit](https://grafana.com/docs/loki/latest/clients/fluentbit)

---

## Getting Started
### Environment Setup
- Use `git submodule update --init --recursive` to update/fetch submodules.
- Use `.env` for local development and `.env.docker` for Docker Compose environments.
- The Kong API Gateway configuration is in `kong/config.yml`.
- **Kong API Gateway** starts on port `8000`.
- **Health check endpoint**: `host:port/health`
- **Swagger documentation**: `host:port/docs`

### Running Locally
Start dependency services first (PostgreSQL, Kafka, Redis):

```bash
docker compose -f docker-compose.local.yml up -d
```

Start core services:
```bash
docker compose up
```

To stop services:
```bash
docker compose -f docker-compose.local.yml down
docker compose down
```

### Running Grafana Stack
To start the Grafana stack locally:
```bash
docker compose -f docker-compose.grafana.yml up -d
```
To stop the Grafana stack:
```bash
docker compose -f docker-compose.grafana.yml down
```

> **Note:** Ensure logging configuration is enabled in `docker-compose.yml` to attach Fluent Bit with service containers.

---

## Setting up Grafana Dashboard Locally
To view logs in Grafana:

1. Open **http://localhost:3000** (default credentials: `admin` / `admin`).
2. Go to **http://localhost:3000/datasources** and add **Loki** from the Logging & Document Databases section.
3. Set the **URL** as `http://loki:3100` (or use the host IP if running separately).
4. Click **Save & Test**.
5. Open **Explore** from the sidebar or visit **http://localhost:3000/explore**.
6. Select containers and run queries.

## Docker Configuration (Services Overview)

### Kong API Gateway
```yaml
services:
  kong:
    image: kong:latest
    environment:
      KONG_DATABASE: "off"
      KONG_DECLARATIVE_CONFIG: /usr/local/kong/declarative/kong.yml
      KONG_PROXY_LISTEN: 0.0.0.0:8000
      KONG_PROXY_LISTEN_SSL: 0.0.0.0:8443
      KONG_ADMIN_LISTEN: 0.0.0.0:8001
    volumes:
      - ./kong/config.yml:/usr/local/kong/declarative/kong.yml
    ports:
      - "8000:8000"
      - "8443:8443"
      - "8001:8001"
    restart: unless-stopped
    networks:
      - backendworks
    logging:
      driver: fluentd
      options:
        fluentd-address: localhost:24224
        tag: kong-gateway
```

### Auth Service
```yaml
  auth-service:
    build:
      context: ./auth
      dockerfile: Dockerfile
    environment:
      - SERVICE_NAME=auth-service
    ports:
      - "9001:9001"
    networks:
      - backendworks
    restart: on-failure
    logging:
      driver: fluentd
      options:
        fluentd-address: localhost:24224
        tag: auth-service
```

### Post Service
```yaml
  post-service:
    build:
      context: ./post
      dockerfile: Dockerfile
    environment:
      - SERVICE_NAME=post-service
    ports:
      - "9002:9002"
    networks:
      - backendworks
    restart: on-failure
    logging:
      driver: fluentd
      options:
        fluentd-address: localhost:24224
        tag: post-service
```

### PostgreSQL
```yaml
  postgres:
    image: postgres:latest
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: master123
      POSTGRES_DB: postgres
    networks:
      - backendworks
```

### Kafka
```yaml
  kafka:
    image: confluentinc/cp-kafka:latest
    restart: unless-stopped
    ports:
      - "9093:9093"
    environment:
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: INTERNAL://kafka:9092,EXTERNAL://localhost:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
    networks:
      - backendworks
```

### Redis
```yaml
  redis:
    image: redis:latest
    restart: always
    ports:
      - "6379:6379"
    command: redis-server --save 20 1 --loglevel warning
    networks:
      - backendworks
```

### Fluent-Bit Logging Service
```yaml
  fluent-bit:
    build:
      context: ./fluent-bit
      dockerfile: Dockerfile
    ports:
      - "24224:24224"
    environment:
      - LOG_LEVEL=debug
      - LOKI_URL=http://loki:3100/loki/api/v1/push
    restart: unless-stopped
    networks:
      - backendworks
```

---

## Networks & Volumes
```yaml
networks:
  backendworks:
    name: backendworks
volumes:
  pg_data:
  zookeeper_data:
  kafka_data:
  redis_data:
  loki_data:
  grafana_data:
```

This documentation provides a clear and structured guide for setting up and managing the NestJS microservices project. Let me know if you need further improvements or additions!

## API Access Guide with Kong API Gateway

### Overview
This guide explains how to access Swagger documentation and interact with APIs when services are running behind Kong API Gateway.

### Prerequisites
- Docker and Docker Compose installed
- Kong API Gateway configured to run on port **8000**
- Services (e.g., `auth-service`, `post-service`) are up and running inside Docker Compose
- Swagger documentation is enabled for each service

### Accessing Swagger Documentation

#### 1. Authentication Service
- Open your browser and navigate to:
  ```
  http://localhost:8000/auth/docs
  ```
- In the Swagger UI, go to the **top-left server selection dropdown**.
- Select `/auth` as the base path.
- Now, you can explore and test API endpoints for the `auth-service`.

#### 2. Post Service
- Open your browser and navigate to:
  ```
  http://localhost:8000/post/docs
  ```
- In the Swagger UI, go to the **top-left server selection dropdown**.
- Select `/post` as the base path.
- Now, you can explore and test API endpoints for the `post-service`.

### Running API Requests via Kong
When making API requests via Swagger UI or any API client (e.g., Postman), ensure you use the Kong API Gateway base URL:
- `http://localhost:8000/auth/...`
- `http://localhost:8000/post/...`

For authentication-protected APIs, add a **Bearer Token** (JWT) in the **Authorization** header.

### Summary
With Kong API Gateway handling the routing, all services are accessible via port `8000`. Swagger provides an interface to test APIs, ensuring smooth API interactions across services.

If you encounter any issues, verify that:
- Docker containers are running.
- Kong configuration includes correct routes.
- Swagger is enabled in each service.


