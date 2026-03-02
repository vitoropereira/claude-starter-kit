# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Running the Application
- `npm run dev` - Start development server with watch mode using tsx (watches `src/server.ts`)
- `npm start` - Start production server (requires build first)
- `npm run build` - Build application using tsup (or tsc)

### Code Quality & Testing
- **Linting**: ESLint with TypeScript Standard style
- **Formatting**: Prettier with single quotes, trailing commas, arrow parens avoidance
- **Type Checking**: Use `tsc --noEmit` for TypeScript type validation
- **Testing**: `npm test` to run test suite (Jest or Vitest)

### Services Management
- `npm run services:up` - Start Docker services (PostgreSQL, Redis, etc.)
- `npm run services:stop` - Stop Docker services
- **Local Database**: PostgreSQL runs in Docker via `compose.yaml`

### Database Management
- **Migration pattern**: `YYYYMMDDHHMI_migration_description.sql`
- Migrations located in `db/migrations/` directory
- Apply migrations manually or via migration runner

### API Testing
- **HTTP files**: `.http` files available for testing API endpoints
- **Location**: Test files in `docs/api-tests/` directory
- **Usage**: Compatible with VS Code REST Client extension

## Architecture Overview

### Core System
This is a Node.js + Express REST API with TypeScript. Update this section with your specific application description.

### Key Components

**Database Layer (`src/infra/database.ts`)**
- PostgreSQL client with connection pooling
- SSL configuration for production environments
- Query interface with automatic connection management

**Authentication (`src/middleware.ts`)**
- Auth middleware with configurable public routes
- Environment-based credentials
- Public routes for health checks and webhooks

**Route Structure (`src/routes/`)**
All routes prefixed with API version (e.g., `/v1/`):
- `health` - Health check and status endpoints
- `users` - User management
- `auth` - Authentication endpoints
- Additional feature routes as needed

### Business Domain Models (`src/models/`)

Define your core entities here:
- **Users**: Customer accounts and profiles
- **[Entity]**: Describe your domain models

### External Integrations

List your required services:
- **Database**: PostgreSQL connection details
- **Cache**: Redis (if applicable)
- **Error Monitoring**: Sentry for error tracking
- **Email**: Transactional email service
- **Payments**: Stripe or equivalent

### Environment Configuration

**Required Environment Variables:**
- Database: `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_DB`, `POSTGRES_PASSWORD`
- Authentication: `AUTH_SECRET` or `JWT_SECRET`
- External services: Connection strings for integrations
- Application: `PORT`, `NODE_ENV`
- **Template**: Use `.env.example` as reference

### Code Organization

**Path Aliases:**
- `@/*` maps to `./src/*` for cleaner imports

**Source Structure:**
```
src/
├── app.ts                    # Express application setup with middleware
├── server.ts                 # Application entry point
├── middleware.ts             # Auth and other middleware
│
├── routes/                   # API route handlers
│   └── index.ts              # Route aggregation and registration
│
├── models/                   # Business domain models and database queries
│   └── [entity].ts           # Entity-specific queries
│
├── controllers/              # Business logic controllers
│   └── [entity]-controller.ts
│
├── infra/                    # Infrastructure layer
│   ├── database.ts           # Database client with connection pooling
│   └── cache.ts              # Cache client (if applicable)
│
├── lib/                      # External service clients
│   ├── [service].ts          # Service-specific clients
│   └── dayjs.ts              # Date library configuration
│
├── utils/                    # Utility functions
│   ├── logs.ts               # Centralized logging
│   └── format-*.ts           # Data formatting utilities
│
├── config/                   # Configuration files
│   └── [config].ts
│
└── errors/                   # Custom error classes
    └── app-error.ts          # Application error class
```

## Development Workflow

### Migration Application Process
When implementing features requiring database changes:
1. Create migration file following timestamp pattern in `db/migrations/`
2. Apply migration to database before testing
3. Update CLAUDE.md with new migration entry

### Testing Workflow
- Use `.http` files for the feature being developed/tested
- Server runs on configured port by default (`npm run dev`)
- API routes may require authentication except public endpoints
- Configure auth credentials via environment variables

### Code Standards
- ESLint with TypeScript Standard style and custom rules
- Prettier for formatting (single quotes, trailing commas)
- TypeScript strict mode with `tsc --noEmit`
- Path aliases: `@/*` maps to `./src/*`
- **Prefer functions over classes** unless absolutely necessary
- Use `express-async-errors` for automatic async error handling

### Important Development Notes
- **Server port**: Configurable via `PORT` env variable
- **Database connections**: Use connection pooling with automatic cleanup
- **Error handling**: Use custom `AppError` class for controlled errors with HTTP status codes
- **Logging**: Use centralized logging utilities
- **Async errors**: Automatically handled via `express-async-errors` — no need for try/catch in route handlers

## Documentation Organization

Organize project documentation in the `docs/` directory:

```
docs/
├── api-tests/         # HTTP request files for testing endpoints
├── architecture/      # System architecture and design docs
├── implementation/    # Feature implementation plans
├── specifications/    # Technical specifications and schemas
└── README.md          # Documentation index
```
