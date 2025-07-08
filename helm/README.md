# NestJS Microservices Helm Chart

This Helm chart deploys a complete NestJS microservices stack with Kong API Gateway on Kubernetes.

## Components

- **Auth Service**: Authentication and user management microservice (port 9001, gRPC 50051)
- **Post Service**: Post management microservice (port 9002, gRPC 50052)  
- **Kong Gateway**: API Gateway for routing and load balancing (port 8000)
- **PostgreSQL**: Database for both microservices (port 5432)
- **Redis**: Cache and session storage (port 6379)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Available storage class for persistent volumes

## Installation

### Quick Start

```bash
# Add and install the chart
helm install microservices ./helm/microservices

# Or with custom values
helm install microservices ./helm/microservices -f custom-values.yaml
```

### Custom Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd nestjs-microservices
   ```

2. **Customize values** (optional):
   ```bash
   cp helm/microservices/values.yaml custom-values.yaml
   # Edit custom-values.yaml as needed
   ```

3. **Install with Helm**:
   ```bash
   helm install microservices ./helm/microservices -f custom-values.yaml
   ```

## Configuration

### Image Configuration

```yaml
auth:
  image:
    repository: auth-service
    tag: latest
    pullPolicy: IfNotPresent

post:
  image:
    repository: post-service
    tag: latest
    pullPolicy: IfNotPresent
```

### Database Configuration

```yaml
postgresql:
  enabled: true
  persistence:
    enabled: true
    size: 10Gi
    storageClass: ""  # Use default storage class
```

### Kong Gateway Configuration

```yaml
kong:
  enabled: true
  service:
    type: LoadBalancer  # Change to NodePort or ClusterIP as needed
    port: 8000
```

### Secrets Management

The chart creates secrets for database credentials and JWT tokens:

```yaml
secrets:
  database:
    create: true
    data:
      url: "postgresql://admin:master123@postgresql-service:5432/postgres"
      password: "master123"
  
  auth:
    create: true
    data:
      jwt-secret: "your-jwt-secret-here"
      jwt-refresh-secret: "your-jwt-refresh-secret-here"
```

**⚠️ Important**: Update these secret values for production deployments!

## Accessing Services

### Via Kong Gateway (Recommended)

```bash
# Get Kong service external IP/port
kubectl get svc microservices-kong

# Auth service endpoints
curl http://<kong-ip>:8000/auth/health

# Post service endpoints  
curl http://<kong-ip>:8000/post/health
```

### Direct Service Access

```bash
# Port forward to auth service
kubectl port-forward svc/microservices-auth 9001:9001

# Port forward to post service
kubectl port-forward svc/microservices-post 9002:9002
```

### Admin Access

```bash
# Kong Admin API
kubectl port-forward svc/microservices-kong 8001:8001
curl http://localhost:8001/status
```

## Ingress Configuration

Enable ingress for external access:

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: microservices.local
      paths:
        - path: /
          pathType: Prefix
          service:
            name: microservices-kong
            port: 8000
```

## Scaling

Scale individual services:

```bash
# Scale auth service
helm upgrade microservices ./helm/microservices --set auth.replicas=3

# Scale post service
helm upgrade microservices ./helm/microservices --set post.replicas=2
```

## Monitoring and Health Checks

All services include health check endpoints:

- Auth Service: `GET /health`
- Post Service: `GET /health`
- Kong Gateway: `kong health` command

## Troubleshooting

### Check pod status
```bash
kubectl get pods -l app.kubernetes.io/name=microservices
```

### View logs
```bash
# Auth service logs
kubectl logs -l app.kubernetes.io/component=auth

# Post service logs
kubectl logs -l app.kubernetes.io/component=post

# Kong logs
kubectl logs -l app.kubernetes.io/component=kong
```

### Debug database connectivity
```bash
# Connect to PostgreSQL
kubectl exec -it deployment/microservices-postgresql -- psql -U admin -d postgres

# Connect to Redis
kubectl exec -it deployment/microservices-redis -- redis-cli ping
```

## Uninstallation

```bash
# Remove the release
helm uninstall microservices

# Clean up persistent volumes (optional)
kubectl delete pvc -l app.kubernetes.io/name=microservices
```

## Development

### Building Custom Images

```bash
# Build auth service
cd auth
docker build -t your-registry/auth-service:tag .

# Build post service  
cd post
docker build -t your-registry/post-service:tag .

# Update values.yaml with new image references
```

### Local Development with Helm

```bash
# Install in development mode
helm install microservices ./helm/microservices \
  --set auth.image.pullPolicy=Always \
  --set post.image.pullPolicy=Always \
  --set kong.service.type=NodePort
```

## Security Considerations

1. **Update default secrets** in production
2. **Use image pull secrets** for private registries
3. **Configure network policies** for pod-to-pod communication
4. **Enable TLS** for ingress and internal communication
5. **Use RBAC** for service account permissions

## Support

For issues and questions:
- Check the troubleshooting section above
- Review Kubernetes events: `kubectl get events --sort-by=.metadata.creationTimestamp`
- Examine pod logs for specific error messages