# NestJS Microservices Architecture

A production-ready microservices architecture built with NestJS, gRPC, PostgreSQL, Redis, and Kong API Gateway. This project demonstrates a scalable, maintainable microservices pattern with proper service communication, authentication, rate limiting, and comprehensive monitoring capabilities.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Kong Gateway  │    │   Auth Service  │    │   Post Service  │
│   (API Gateway) │◄──►│   (Port: 9001)  │◄──►│   (Port: 9002)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │     Redis       │    │   Monitoring    │
│   (Database)    │    │    (Cache)      │    │   (Health)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Features

### Core Services
- **Auth Service**: User authentication, authorization, and JWT token management
- **Post Service**: Blog post management with user integration
- **Kong API Gateway**: Centralized API routing and management
- **PostgreSQL**: Primary database for data persistence
- **Redis**: Caching layer for performance optimization

### Technical Features
- **gRPC Communication**: High-performance inter-service communication
- **JWT Authentication**: Secure token-based authentication
- **Role-based Authorization**: ADMIN and USER role support
- **Rate Limiting**: Kong-based API rate limiting with configurable thresholds
- **Soft Delete**: Audit trails for data integrity
- **Pagination**: Efficient data pagination
- **Search & Filtering**: Advanced search capabilities
- **Health Monitoring**: Built-in health checks
- **API Documentation**: Swagger/OpenAPI documentation
- **Docker Support**: Containerized deployment
- **Database Migrations**: Automated schema management
- **Test Coverage**: Comprehensive unit and integration tests

## 📋 Prerequisites

- **Docker & Docker Compose**: For containerized deployment
- **Node.js >= 18.0.0**: For local development
- **npm >= 9.0.0**: Package manager
- **Git**: Version control

## 🛠️ Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd nestjs-microservices
```

### 2. Environment Setup
Create environment files for each service:

**Auth Service** (`auth/.env.docker`):
```env
NODE_ENV=development
APP_NAME=NestJS Auth Service
APP_DEBUG=false
APP_CORS_ORIGINS=http://localhost:3000

HTTP_ENABLE=true
HTTP_HOST=0.0.0.0
HTTP_PORT=9001
HTTP_VERSIONING_ENABLE=false
HTTP_VERSION=1

DATABASE_URL=postgresql://admin:master123@postgres:5432/postgres

ACCESS_TOKEN_SECRET_KEY=your-access-token-secret-key-min-32-chars
ACCESS_TOKEN_EXPIRED=15m
REFRESH_TOKEN_SECRET_KEY=your-refresh-token-secret-key-min-32-chars
REFRESH_TOKEN_EXPIRED=7d

REDIS_URL=redis://redis:6379
REDIS_KEY_PREFIX=auth:
REDIS_TTL=3600

GRPC_URL=0.0.0.0:50051
GRPC_PACKAGE=auth
```

**Post Service** (`post/.env.docker`):
```env
NODE_ENV=development
APP_NAME=NestJS Post Service
APP_DEBUG=false
APP_CORS_ORIGINS=http://localhost:3000

HTTP_ENABLE=true
HTTP_HOST=0.0.0.0
HTTP_PORT=9002
HTTP_VERSIONING_ENABLE=false
HTTP_VERSION=1

DATABASE_URL=postgresql://admin:master123@postgres:5432/postgres

REDIS_URL=redis://redis:6379
REDIS_KEY_PREFIX=post:
REDIS_TTL=3600

GRPC_URL=0.0.0.0:50052
GRPC_PACKAGE=post
```

### 3. Start the Services
```bash
# Start all services with Docker Compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### 4. Database Setup
```bash
# Run database migrations for Auth Service
docker-compose exec auth-service npm run prisma:migrate

# Run database migrations for Post Service
docker-compose exec post-service npm run prisma:migrate
```

### 5. Verify Installation
```bash
# Check all services are running
docker-compose ps

# Test Kong API Gateway
curl http://localhost:8000/auth  # Should return auth service info
curl http://localhost:8000/post  # Should return post service info

# Check rate limiting headers
curl -I http://localhost:8000/auth | grep RateLimit

# Verify health endpoints
curl http://localhost:9001/health
curl http://localhost:9002/health
```

## 📡 Service Endpoints

### Kong API Gateway
- **URL**: `http://localhost:8000`
- **Admin API**: `http://localhost:8001`
- **Auth Service**: `http://localhost:8000/auth` (Rate limit: 100/min, 1000/hour, 10000/day)
- **Post Service**: `http://localhost:8000/post` (Rate limit: 200/min, 2000/hour, 20000/day)
- **Global Rate Limit**: 300/min, 3000/hour, 30000/day

### Direct Service Access

#### Auth Service
- **HTTP API**: `http://localhost:9001`
- **gRPC**: `localhost:50051`
- **Health Check**: `http://localhost:9001/health`
- **API Docs**: `http://localhost:9001/docs`

#### Post Service
- **HTTP API**: `http://localhost:9002`
- **gRPC**: `localhost:50052`
- **Health Check**: `http://localhost:9002/health`
- **API Docs**: `http://localhost:9002/docs`

### Database & Cache
- **PostgreSQL**: `localhost:5432`
- **Redis**: `localhost:6379`

## 🔌 API Endpoints

### Authentication (via Kong: `/auth`)
```http
POST /auth/signup          # User registration
POST /auth/login           # User login
POST /auth/refresh         # Refresh access token
GET  /auth/profile         # Get user profile (protected)
PUT  /auth/profile         # Update user profile (protected)
POST /auth/logout          # User logout (protected)
```

### User Management (via Kong: `/auth`)
```http
GET    /auth/admin/users           # List users (admin only)
GET    /auth/admin/users/:id       # Get user by ID (admin only)
PUT    /auth/admin/users/:id       # Update user (admin only)
DELETE /auth/admin/users/:id       # Delete user (admin only)
```

### Post Management (via Kong: `/post`)
```http
GET    /post/posts                 # List posts (paginated)
GET    /post/posts/:id             # Get post by ID
POST   /post/posts                 # Create post (protected)
PUT    /post/posts/:id             # Update post (protected)
DELETE /post/posts/:id             # Delete post (protected)
POST   /post/posts/bulk-delete     # Bulk delete posts (protected)
```

## 🗄️ Database Schema

### Users Table (Auth Service)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR UNIQUE NOT NULL,
  password VARCHAR,
  first_name VARCHAR,
  last_name VARCHAR,
  avatar VARCHAR,
  is_verified BOOLEAN DEFAULT false,
  phone_number VARCHAR,
  role Role NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP
);

CREATE TYPE Role AS ENUM ('ADMIN', 'USER');
```

### Posts Table (Post Service)
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR NOT NULL,
  content TEXT NOT NULL,
  images TEXT[] DEFAULT '{}',
  created_by UUID NOT NULL,
  updated_by UUID,
  deleted_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT false
);
```

## 🔧 Configuration

### Kong API Gateway Configuration
- **Port**: 8000 (HTTP), 8443 (HTTPS)
- **Admin API**: 8001
- **Configuration**: Declarative configuration in `kong/config.yml`
- **Rate Limiting**: Configured per service with different thresholds
  - Auth Service: 100 requests/minute, 1000/hour, 10000/day
  - Post Service: 200 requests/minute, 2000/hour, 20000/day
  - Global: 300 requests/minute, 3000/hour, 30000/day
- **Features**: Load balancing, health checks, request/response transformation

#### Kong Rate Limiting Configuration

The Kong API Gateway is configured with rate limiting plugins to protect against abuse:

```yaml
# kong/config.yml
plugins:
  - name: rate-limiting
    route: auth-routes
    config:
      minute: 100
      hour: 1000
      day: 10000
      policy: local
      hide_client_headers: false
      fault_tolerant: true

  - name: rate-limiting
    route: post-routes
    config:
      minute: 200
      hour: 2000
      day: 20000
      policy: local
      hide_client_headers: false
      fault_tolerant: true
```

**Rate Limiting Headers:**
- `X-RateLimit-Limit-Minute`: Maximum requests per minute
- `X-RateLimit-Remaining-Minute`: Remaining requests in current minute
- `RateLimit-Reset`: Seconds until rate limit window resets

**Testing Rate Limits:**
```bash
# Test rate limiting
for i in {1..105}; do curl -s -w "Request $i: %{http_code}\n" -o /dev/null http://localhost:8000/auth; done

# Expected: First 100 requests return 200, subsequent requests return 429
```

### Service Communication
- **gRPC**: High-performance binary protocol for inter-service communication
- **HTTP**: RESTful APIs for external clients
- **Authentication**: JWT tokens for service-to-service communication

### Environment Variables
Each service supports environment-specific configuration:
- **Development**: `.env.docker` for Docker deployment
- **Production**: Environment variables for production deployment

## 🧪 Development

### Local Development
```bash
# Start individual services
cd auth && npm run dev
cd post && npm run dev

# Run tests
cd auth && npm test
cd post && npm test

# Database operations
npm run prisma:generate
npm run prisma:migrate
npm run prisma:studio
```

### Docker Development
```bash
# Build and start services
docker-compose up --build

# View service logs
docker-compose logs -f auth-service
docker-compose logs -f post-service

# Access service shells
docker-compose exec auth-service sh
docker-compose exec post-service sh
```

### Database Management
```bash
# Access PostgreSQL
docker-compose exec postgres psql -U admin -d postgres

# Access Redis
docker-compose exec redis redis-cli

# Run migrations
docker-compose exec auth-service npm run prisma:migrate
docker-compose exec post-service npm run prisma:migrate
```

## 📊 Monitoring & Health Checks

### Health Endpoints
- **Auth Service**: `http://localhost:9001/health`
- **Post Service**: `http://localhost:9002/health`
- **Kong Gateway**: `http://localhost:8001/status`
- **Kong Health Check**: `curl http://localhost:8000/auth` (should return service response)

### Docker Health Checks
All services include Docker health checks for container orchestration:
- **Auth Service**: HTTP health check on port 9001
- **Post Service**: HTTP health check on port 9002
- **PostgreSQL**: Database connectivity check
- **Redis**: Cache connectivity check

## 🔒 Security Features

### Authentication & Authorization
- **JWT Tokens**: Access and refresh token system
- **Role-based Access**: ADMIN and USER role support
- **Password Hashing**: bcrypt password security
- **Token Validation**: gRPC-based token validation

### API Security
- **CORS Protection**: Cross-origin request handling
- **Helmet Security**: Security headers
- **Input Validation**: Request validation with class-validator
- **Rate Limiting**: Kong-based rate limiting with per-service thresholds
- **API Gateway Security**: Centralized security policies through Kong

### Infrastructure Security
- **Network Isolation**: Docker network isolation
- **Environment Variables**: Secure configuration management
- **Health Checks**: Service health monitoring

## 🚀 Deployment

### Production Deployment
```bash
# Build production images
docker-compose -f docker-compose.prod.yml up --build

# Scale services
docker-compose up --scale auth-service=3 --scale post-service=3
```

### Environment Configuration
Set production environment variables:
```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db

# Redis
REDIS_URL=redis://host:6379

# JWT Secrets
ACCESS_TOKEN_SECRET_KEY=your-production-secret
REFRESH_TOKEN_SECRET_KEY=your-production-secret

# Service URLs
AUTH_SERVICE_URL=grpc://auth-service:50051
```

### Database Migrations
```bash
# Run production migrations
docker-compose exec auth-service npm run prisma:migrate:prod
docker-compose exec post-service npm run prisma:migrate:prod
```

## 📚 Documentation

### Service Documentation
- **[Auth Service](./auth/README.md)**: Authentication and user management
- **[Post Service](./post/README.md)**: Post management and content

### API Documentation
- **Auth Service**: `http://localhost:9001/docs`
- **Post Service**: `http://localhost:9002/docs`

### Architecture Documentation
- **gRPC Services**: Protocol buffer definitions in `*/src/protos/`
- **Database Schema**: Prisma schema files in `*/prisma/schema.prisma`
- **Kong Configuration**: API gateway config in `kong/config.yml`

## 🛠️ Troubleshooting

### Common Issues

#### Service Won't Start
```bash
# Check service logs
docker-compose logs auth-service
docker-compose logs post-service

# Check health status
curl http://localhost:9001/health
curl http://localhost:9002/health
```

#### Database Connection Issues
```bash
# Check PostgreSQL status
docker-compose exec postgres pg_isready -U admin

# Check Redis status
docker-compose exec redis redis-cli ping
```

#### gRPC Communication Issues
```bash
# Check gRPC ports
netstat -an | grep 50051
netstat -an | grep 50052
```

#### Kong Gateway Issues
```bash
# Check Kong status
curl http://localhost:8001/status

# Check Kong configuration
curl http://localhost:8001/services
curl http://localhost:8001/routes
curl http://localhost:8001/plugins

# Check rate limiting status
curl -I http://localhost:8000/auth  # Check headers for rate limit info

# Restart Kong if needed
docker-compose restart kong
```

### Development Tips
- Use `docker-compose logs -f` to monitor service logs
- Check health endpoints for service status
- Use Prisma Studio for database inspection: `npm run prisma:studio`
- Monitor Kong gateway logs for API routing issues
- Test rate limiting with the provided script: `./test-rate-limiting.sh`

### Testing the System
```bash
# Test all services are running
curl http://localhost:8000/auth
curl http://localhost:8000/post

# Test rate limiting
for i in {1..10}; do curl -s -w "Request $i: %{http_code}\n" -o /dev/null http://localhost:8000/auth; done

# Test health endpoints
curl http://localhost:9001/health
curl http://localhost:9002/health
curl http://localhost:8001/status

# Check service logs
docker-compose logs auth-service --tail 20
docker-compose logs post-service --tail 20
docker-compose logs kong --tail 20
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** and add tests
4. **Run tests**: `npm test`
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines
- Follow the existing code structure and patterns
- Add tests for new functionality
- Update documentation for API changes
- Ensure all services start successfully
- Test inter-service communication

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 

## 🆘 Support

### Getting Help
- **Issues**: Create an issue in the repository
- **Documentation**: Check service-specific README files
- **Health Checks**: Use health endpoints for service status

### Community
- **Discussions**: Use GitHub Discussions for questions
- **Contributions**: Pull requests are welcome
- **Feedback**: Open issues for bugs or feature requests

## 🙏 Acknowledgments

- **NestJS Team**: For the excellent framework
- **Prisma Team**: For the database toolkit
- **Kong Team**: For the API gateway
- **Docker Team**: For containerization technology

---

**Built with ❤️ using NestJS, gRPC, and modern microservices patterns**




