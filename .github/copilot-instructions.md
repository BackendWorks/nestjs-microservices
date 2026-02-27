# Copilot Instructions – NestJS Microservices

## Architecture Overview

Four independent NestJS apps plus two versioned shared database packages, all behind a **Kong API Gateway**.

```
Client → Kong (:8000) → auth-service (:9001) / post-service (:9002)
                              ↕ gRPC (:50051 / :50052)

auth-service  ──uses──► @backendworks/auth-db  (npm package, GitHub Packages)
auth-worker   ──uses──► @backendworks/auth-db
post-service  ──uses──► @backendworks/post-db  (npm package, GitHub Packages)
post-worker   ──uses──► @backendworks/post-db

Both packages internally use Prisma but expose an ORM-agnostic repository interface
so the underlying ORM can be swapped without touching any service.
```

### Apps and their repositories

| App            | HTTP port | gRPC port | DB package              |
| -------------- | --------- | --------- | ----------------------- |
| `auth-service` | 9001      | 50051     | `@backendworks/auth-db` |
| `auth-worker`  | —         | 50053     | `@backendworks/auth-db` |
| `post-service` | 9002      | 50052     | `@backendworks/post-db` |
| `post-worker`  | —         | 50054     | `@backendworks/post-db` |

### Shared packages and their repositories

| Package                 | npm scope           | Prisma schema covers |
| ----------------------- | ------------------- | -------------------- |
| `@backendworks/auth-db` | `packages/auth-db/` | `User`, `Role`       |
| `@backendworks/post-db` | `packages/post-db/` | `Post`               |

**Auth flow in `post`**: The `AuthJwtAccessGuard` in `post` does **not** use Passport — it calls Auth service via gRPC (`GrpcAuthService.validateToken`) to verify Bearer tokens on every protected request. Authenticated user (`id`, `role`) is attached to `request.user`.

## gRPC Code Generation

Proto files live in `src/protos/`. TypeScript types are **auto-generated** into `src/generated/` — never edit these files manually.

```bash
# Must run before dev or after editing any .proto file
npm run proto:generate   # runs: nestjs-grpc generate --proto ./src/protos --output ./src/generated
npm run dev              # automatically runs proto:generate first
```

- `auth-service` exposes: `ValidateToken` (used by post-service guard)
- `auth-worker` exposes: worker-specific RPCs (email dispatch, async user ops)
- `post-service` exposes: `CreatePost`, `GetPost`, `GetPosts`, `UpdatePost`, `DeletePost`
- `post-worker` exposes: worker-specific RPCs (indexing, async post ops)
- gRPC controllers use `@GrpcController` / `@GrpcMethod` decorators from `nestjs-grpc`

## Developer Workflows

All commands run **per-app** from the app's own directory:

```bash
npm run dev                  # watch mode (proto:generate → nest start --watch)
npm run test                 # unit tests with 100% coverage enforced
```

Shared package commands run from `packages/auth-db/` or `packages/post-db/`:

```bash
npm run prisma:migrate       # dotenv -e .env -- prisma migrate dev
npm run prisma:generate      # regenerates Prisma client from schema
npm run prisma:studio        # opens Prisma Studio
npm run build                # tsc compile → dist/ for publishing
```

Full stack via Docker:

```bash
docker-compose up --build    # from repo root
```

**Database migrations are owned by the packages, not the apps.** Never add a `schema.prisma` inside an app. Always run `prisma migrate dev` from `packages/auth-db/` or `packages/post-db/`.

## Shared Database Packages (`packages/`)

### ORM-Agnostic Design

Each package exposes a repository interface layer. Apps and workers import repositories, never `PrismaClient` directly:

```typescript
// apps import this interface — never PrismaClient
import { IUserRepository, createAuthDbManager } from "@backendworks/auth-db";

// The package wires Prisma internally; swap to TypeORM/Drizzle by replacing
// the implementation only — the interface stays the same
```

### Package structure (same pattern for both)

```
packages/auth-db/
  src/
    client/
      prisma.client.ts             # PrismaClient singleton factory
    repositories/
      user.repository.ts           # Implements IUserRepository using Prisma
    interfaces/
      user.repository.interface.ts # IUserRepository — ORM-agnostic contract
      db-manager.interface.ts      # IAuthDbManager — top-level export shape
    operations/
      base.operations.ts           # Generic findById, findOne, findMany,
                                   #   create, update, softDelete helpers
    index.ts                       # Public API: export interfaces + createAuthDbManager()
  prisma/
    schema.prisma                  # Schema owned here — apps have NO schema.prisma
  package.json                     # name: "@backendworks/auth-db", semver versioned
```

### Versioning rule

- Any **schema change** → bump minor version of the package
- Any **breaking interface change** → bump major version
- Apps and their paired worker must always pin to the **same version range**

## Project-Specific Patterns

### Response Shape

Every HTTP response is wrapped by `ResponseInterceptor` into:

```json
{ "statusCode": 200, "timestamp": "...", "message": "...", "data": { ... } }
```

Controllers annotate the response message key via `@MessageKey('auth.success.login', AuthResponseDto)`. Messages are resolved via `nestjs-i18n` from `src/languages/en/`.

### Swagger DTOs

Use `SwaggerResponse(Dto)` / `SwaggerArrayResponse(Dto)` helpers (in `common/dtos/api-response.dto.ts`) for `@ApiResponse` types — do not inline response shapes directly.

### Authorization Decorators

```typescript
@PublicRoute()           // skips JWT guard entirely
@AdminOnly()             // sets ADMIN role + adds ApiBearerAuth to Swagger
@UserAndAdmin()          // sets USER|ADMIN roles
@AuthUser() user         // extracts IAuthPayload from request
```

### Pagination & Querying

Extend `ApiBaseQueryDto` for list endpoints. Use `QueryBuilderService.findManyWithPagination()` with `searchFields`, `relations`, and `customFilters` — it automatically adds `deletedAt: null` soft-delete filtering.

### Config Pattern

All env vars are registered via typed `registerAs()` factories in `src/common/config/` and validated with Joi in `CommonModule`. Access via `configService.get<T>('namespace.key')`, never `process.env` directly in services.

### Soft Delete

Both schemas use `deletedAt DateTime?`. `QueryBuilderService` always filters `deletedAt: null`. Post schema also has `isDeleted Boolean`.

## Testing

- Tests are in `test/unit/` and match `*.spec.ts`
- **100% branch/function/line/statement coverage is enforced** — CI will fail below this threshold
- All service dependencies are mocked manually (no `@nestjs/testing` auto-mocking); see `auth.service.spec.ts` for the mock pattern
- `jest --config test/jest.json --runInBand` — runs serially (no parallel test execution)
- Coverage excludes `src/generated/`, `src/main.ts`, controller files, and `swagger.ts`

## Key Files

| Path                                             | Purpose                                                    |
| ------------------------------------------------ | ---------------------------------------------------------- |
| `auth/src/app/auth.grpc.controller.ts`           | gRPC server endpoint for token validation                  |
| `post/src/services/auth/grpc.auth.service.ts`    | gRPC client calling auth from post                         |
| `post/src/common/guards/jwt.access.guard.ts`     | Auth guard using gRPC (not Passport)                       |
| `auth/src/common/common.module.ts`               | Central module wiring: config, cache, guards, interceptors |
| `*/src/common/services/query-builder.service.ts` | Reusable paginated query builder                           |
| `kong/config.yml`                                | Declarative Kong config: routes, rate-limiting plugin      |
| `packages/auth-db/src/index.ts`                  | Public API of the auth-db shared package                   |
| `packages/post-db/src/index.ts`                  | Public API of the post-db shared package                   |

## Service Folder Structure

Both services follow the same internal layout. Differences are noted inline.

### `auth/src/`

```
app/
  app.module.ts               # Root module — wires CommonModule, AuthModule, UserModule, GrpcModule
  app.controller.ts           # Health check endpoint (/health)
  auth.grpc.controller.ts     # gRPC server: exposes ValidateToken RPC
common/
  common.module.ts            # Global providers: config, cache, guards, interceptors, i18n
  config/                     # registerAs() typed config factories
    app.config.ts             #   → 'app.*' namespace
    auth.config.ts            #   → 'auth.*' (JWT secrets, expiry)
    grpc.config.ts            #   → 'grpc.*'
    redis.config.ts           #   → 'redis.*'
    doc.config.ts             #   → 'doc.*' (Swagger)
  guards/
    jwt.access.guard.ts       # Passport-based access token guard (uses JWT strategy)
    jwt.refresh.guard.ts      # Passport-based refresh token guard
    roles.guard.ts            # Checks ROLES_DECORATOR_KEY metadata against request.user.role
  providers/
    jwt.access.strategy.ts    # PassportStrategy — validates access token, populates request.user
    jwt.refresh.strategy.ts   # PassportStrategy — validates refresh token
  services/
    hash.service.ts           # bcrypt helpers (createHash, match)
    query-builder.service.ts  # findManyWithPagination() — delegates to IUserRepository
  decorators/                 # @PublicRoute, @AdminOnly, @UserAndAdmin, @AuthUser, @MessageKey
  dtos/                       # ApiBaseQueryDto, SwaggerResponse(), SwaggerArrayResponse()
  filters/                    # ResponseExceptionFilter (Sentry-integrated)
  interceptors/               # ResponseInterceptor (wraps all HTTP responses)
  middlewares/                # RequestMiddleware (request-id, structured HTTP logging)
  interfaces/                 # IAuthPayload, IApiResponse, IErrorResponse, QueryBuilderOptions
  constants/                  # REQUEST / RESPONSE metadata key strings
languages/en/
  auth.json                   # i18n keys: auth.success.login / signup / refresh
  user.json                   # i18n keys: user.*
  http.json                   # i18n keys: generic HTTP status messages
modules/
  auth/
    controllers/
      auth.public.controller.ts   # POST /auth/login, POST /auth/signup, GET /auth/refresh
    services/
      auth.service.ts             # login(), signup(), verifyToken(), refreshToken()
    dtos/                         # AuthLoginDto, AuthSignupDto, AuthResponseDto
    interfaces/                   # IAuthPayload, ITokenResponse, TokenType enum
  user/
    controllers/
      user.auth.controller.ts     # GET /user/me — authenticated user profile
      user.admin.controller.ts    # Admin CRUD for users
    services/
      user.auth.service.ts        # getUserProfileByEmail(), createUser()
      user.admin.service.ts       # findAll(), findOne(), update(), delete() — admin ops
    dtos/                         # UserResponseDto, UserUpdateDto
protos/
  auth.proto                  # Defines AuthService { ValidateToken }
generated/
  auth.ts                     # Auto-generated types from auth.proto — DO NOT EDIT
```

### `post/src/`

```
app/
  app.module.ts               # Root module — wires CommonModule, PostModule, GrpcModule
  app.controller.ts           # Health check endpoint (/health)
  post.grpc.controller.ts     # gRPC server: CreatePost, GetPost, GetPosts, UpdatePost, DeletePost
common/
  common.module.ts            # Same role as auth — also registers GrpcAuthService as provider
  config/                     # registerAs() factories (no auth.config; grpc, redis, app, doc)
  guards/
    jwt.access.guard.ts       # gRPC-based guard — calls GrpcAuthService.validateToken (NOT Passport)
    roles.guard.ts            # Same pattern as auth
  services/
    hash.service.ts           # bcrypt helpers
    query-builder.service.ts  # Same as auth — delegates to IPostRepository
  decorators/                 # Same set as auth
  dtos/                       # ApiBaseQueryDto, SwaggerResponse(), SwaggerArrayResponse()
  filters/                    # ResponseExceptionFilter
  interceptors/               # ResponseInterceptor
  middlewares/                # RequestMiddleware
  enums/                      # (post-specific enums, e.g. post status)
languages/en/
  post.json                   # i18n keys: post.*
  auth.json                   # i18n keys for generic auth errors
  http.json                   # Generic HTTP status messages
modules/
  post/
    controllers/
      post.controller.ts          # REST CRUD: POST, GET /:id, GET /, PATCH /:id, DELETE /:id
    services/
      post.service.ts             # create(), findAll(), findOne(), update(), remove()
      post-mapping.service.ts     # Maps Prisma Post → PostResponseDto (enriches with author data)
    dtos/                         # PostCreateDto, PostUpdateDto, PostResponseDto, PostListDto
    interfaces/                   # IPostService
services/
  auth/
    grpc.auth.service.ts      # gRPC client — calls auth-service ValidateToken (and GetUserById)
protos/
  auth.proto                  # Copy of auth.proto for client-side type generation
  post.proto                  # Defines PostService RPCs
generated/
  auth.ts                     # Auto-generated from auth.proto — DO NOT EDIT
  post.ts                     # Auto-generated from post.proto — DO NOT EDIT
```

### `auth-worker/src/`

```
app/
  app.module.ts               # Wires CommonModule, worker modules, GrpcModule (:50053)
  worker.grpc.controller.ts   # gRPC server: async auth job RPCs
common/
  common.module.ts            # No HTTP guards, no Passport, no Swagger
  config/                     # app, grpc, redis only — no auth.config, no doc.config
  services/
    queue.service.ts          # Redis-backed job queue consumer
modules/
  email/                      # Email dispatch jobs triggered by auth events
  cleanup/                    # Scheduled token-revocation / soft-delete cleanup jobs
protos/
  auth-worker.proto           # Worker-specific RPC definitions
generated/
  auth-worker.ts              # Auto-generated — DO NOT EDIT
```

### `post-worker/src/`

```
app/
  app.module.ts               # Wires CommonModule, worker modules, GrpcModule (:50054)
  worker.grpc.controller.ts   # gRPC server: async post job RPCs
common/
  common.module.ts            # No HTTP guards, no Swagger
  config/                     # app, grpc, redis only
  services/
    queue.service.ts          # Redis-backed job queue consumer
modules/
  indexing/                   # Search index sync jobs triggered by post events
  media/                      # Image processing / storage jobs
protos/
  post-worker.proto           # Worker-specific RPC definitions
generated/
  post-worker.ts              # Auto-generated — DO NOT EDIT
```

### `packages/auth-db/`

```
prisma/
  schema.prisma               # User + Role schema — source of truth for auth DB
  migrations/                 # All auth DB migrations live here
src/
  client/
    prisma.client.ts          # PrismaClient singleton factory
  interfaces/
    user.repository.interface.ts  # IUserRepository (ORM-agnostic contract)
    db-manager.interface.ts       # IAuthDbManager — top-level export shape
  repositories/
    user.repository.ts        # Implements IUserRepository using Prisma
  operations/
    base.operations.ts        # Generic: findById, findOne, findMany, create, update, softDelete
  index.ts                    # Public API: IAuthDbManager, IUserRepository, createAuthDbManager()
package.json                  # name: "@backendworks/auth-db", published to GitHub Packages
```

### `packages/post-db/`

```
prisma/
  schema.prisma               # Post schema — source of truth for post DB
  migrations/                 # All post DB migrations live here
src/
  client/
    prisma.client.ts          # PrismaClient singleton factory
  interfaces/
    post.repository.interface.ts  # IPostRepository (ORM-agnostic contract)
    db-manager.interface.ts       # IPostDbManager — top-level export shape
  repositories/
    post.repository.ts        # Implements IPostRepository using Prisma
  operations/
    base.operations.ts        # Same generic helpers as auth-db
  index.ts                    # Public API: IPostDbManager, IPostRepository, createPostDbManager()
package.json                  # name: "@backendworks/post-db", published to GitHub Packages
```
