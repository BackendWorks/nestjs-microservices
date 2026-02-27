# NestJS Microservices

[![NestJS](https://img.shields.io/badge/NestJS-11.x-red.svg)](https://nestjs.com/)
[![Node.js](https://img.shields.io/badge/Node.js-%3E%3D18.0.0-green.svg)](https://nodejs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-blue.svg)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Production-ready NestJS microservices monorepo — JWT auth, post management, async workers, shared ORM-agnostic database packages, Kong API gateway, and gRPC inter-service communication.

## Architecture

```
Client → Kong (:8000) → auth-service (:9001)
                      → post-service (:9002)

auth-service  ←gRPC→  post-service   (token validation on every request)
auth-service  ←gRPC→  auth-worker    (:50053, async jobs)
post-service  ←gRPC→  post-worker    (:50054, async jobs)

auth-service  ──uses──► @backendworks/auth-db  (User, Role)
auth-worker   ──uses──► @backendworks/auth-db
post-service  ──uses──► @backendworks/post-db  (Post)
post-worker   ──uses──► @backendworks/post-db
```

### Repositories

| Repo | Type | HTTP | gRPC | DB Package |
|---|---|---|---|---|
| [auth-service](https://github.com/BackendWorks/auth-service) | Service | `:9001` | `:50051` | `@backendworks/auth-db` |
| [post-service](https://github.com/BackendWorks/post-service) | Service | `:9002` | `:50052` | `@backendworks/post-db` |
| [auth-worker](https://github.com/BackendWorks/auth-worker) | Worker | — | `:50053` | `@backendworks/auth-db` |
| [post-worker](https://github.com/BackendWorks/post-worker) | Worker | — | `:50054` | `@backendworks/post-db` |
| [auth-db](https://github.com/BackendWorks/auth-db) | Package | — | — | Prisma (User, Role) |
| [post-db](https://github.com/BackendWorks/post-db) | Package | — | — | Prisma (Post) |

## Key Design Decisions

- **gRPC-based auth in post-service** — `post-service` validates Bearer tokens by calling `auth-service` via gRPC (`ValidateToken`). No Passport. Authenticated user (`id`, `role`) is injected into `request.user`.
- **ORM-agnostic packages** — `auth-db` and `post-db` expose repository interfaces (`IUserRepository`, `IPostRepository`). Apps never import `PrismaClient` directly. Swap the ORM by changing only the package internals.
- **Database migrations owned by packages** — Never add a `schema.prisma` inside an app or worker. Run `prisma migrate dev` from `packages/auth-db/` or `packages/post-db/`.
- **Workers are async consumers** — `auth-worker` handles email dispatch and cleanup jobs. `post-worker` handles search indexing and media processing. Both communicate via gRPC and Redis queues.

## Quick Start

### Docker (recommended)

```bash
git clone --recurse-submodules https://github.com/BackendWorks/nestjs-microservices.git
cd nestjs-microservices
docker-compose up --build
```

Services will be available at:
- **Kong Gateway**: `http://localhost:8000`
- **Auth Service**: `http://localhost:9001` — Swagger at `/docs`
- **Post Service**: `http://localhost:9002` — Swagger at `/docs`

### Local Development

Each app is developed independently from its own directory:

```bash
# Auth Service
cd auth-service && npm install && npm run dev

# Post Service
cd post-service && npm install && npm run dev

# Auth Worker
cd auth-worker && npm install && npm run dev

# Post Worker
cd post-worker && npm install && npm run dev
```

> **Note:** `npm run proto:generate` must be run before first start or after editing `.proto` files. `npm run dev` does this automatically.

## Environment Variables

### Auth Service (`.env`)

```env
NODE_ENV=local
APP_PORT=9001
DATABASE_URL=postgresql://admin:master123@localhost:5432/postgres?schema=public
ACCESS_TOKEN_SECRET_KEY=your-access-secret
ACCESS_TOKEN_EXPIRED=1d
REFRESH_TOKEN_SECRET_KEY=your-refresh-secret
REFRESH_TOKEN_EXPIRED=7d
REDIS_URL=redis://localhost:6379
REDIS_KEY_PREFIX=auth:
REDIS_TTL=3600
GRPC_URL=0.0.0.0:50051
```

### Post Service (`.env`)

```env
NODE_ENV=local
APP_PORT=9002
DATABASE_URL=postgresql://admin:master123@localhost:5432/postgres?schema=public
ACCESS_TOKEN_SECRET_KEY=your-access-secret
REDIS_URL=redis://localhost:6379
REDIS_KEY_PREFIX=post:
REDIS_TTL=3600
GRPC_URL=0.0.0.0:50052
GRPC_AUTH_URL=0.0.0.0:50051
```

## API Endpoints

All external traffic routes through Kong on `:8000`.

### Auth (`/auth`)

| Method | Path | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/login` | Public | Login, returns access + refresh tokens |
| `POST` | `/auth/signup` | Public | Register new user |
| `GET` | `/auth/refresh` | Bearer (refresh) | Rotate tokens |
| `GET` | `/user/me` | Bearer | Get authenticated user profile |
| `GET` | `/admin/user` | Admin | List users (paginated) |
| `PATCH` | `/admin/user/:id` | Admin | Update user |
| `DELETE` | `/admin/user/:id` | Admin | Soft-delete user |

### Posts (`/post`)

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/post` | Public | List posts (paginated, searchable) |
| `POST` | `/post` | Bearer | Create post |
| `GET` | `/post/:id` | Bearer | Get post by ID |
| `PATCH` | `/post/:id` | Bearer | Update post |
| `DELETE` | `/post/:id` | Bearer | Soft-delete post |

### Health

```
GET http://localhost:9001/health
GET http://localhost:9002/health
```

## Database Migrations

Migrations are owned by the shared packages, not the apps.

```bash
# Auth domain
cd packages/auth-db
npm run prisma:migrate     # prisma migrate dev
npm run prisma:generate    # regenerate Prisma client
npm run prisma:studio      # open Prisma Studio

# Post domain
cd packages/post-db
npm run prisma:migrate
npm run prisma:generate
npm run prisma:studio
```

## Testing

All services enforce **100% branch/function/line/statement coverage**.

```bash
cd auth-service && npm test
cd post-service && npm test
cd auth-worker  && npm test
cd post-worker  && npm test
```

## Kong Rate Limits

Configured declaratively in `kong/config.yml`:

| Route | Limit |
|---|---|
| Auth routes | 100 req/min |
| Post routes | 200 req/min |
| Global | 300 req/min |

## GitHub Packages

`@backendworks/auth-db` and `@backendworks/post-db` are published to GitHub Packages. Ensure `~/.npmrc` contains:

```
@backendworks:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=YOUR_GITHUB_PAT
```

## License

[MIT](LICENSE)
