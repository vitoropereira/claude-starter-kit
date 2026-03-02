# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Next.js project with TypeScript, optimized for modern web development with server-side rendering (SSR) and static site generation (SSG) capabilities.

## Hierarchical CLAUDE.md System

This project uses a hierarchical CLAUDE.md system for context management:
- **Root `CLAUDE.md`** (this file): Project-wide standards, architecture, and commands
- **Directory-level `CLAUDE.md`**: Specific guidelines for components, pages, API routes, etc.
- When working in a subdirectory, always check for a local `CLAUDE.md` first, then fall back to this root file
- Directory-level instructions take precedence over root instructions for that specific area

## Context & Session Management

When starting a new session:
1. Read this `CLAUDE.md` first for project-wide context
2. Check for relevant directory-level `CLAUDE.md` files in your working area
3. Review recent git history to understand current state: `git log --oneline -10`
4. Check for any in-progress work: `git status` and `git stash list`

## Development Commands

### Package Management
- `npm install` or `pnpm install` - Install dependencies
- `npm ci` or `pnpm install --frozen-lockfile` - Install dependencies for CI/CD

### Build Commands
- `npm run dev` or `pnpm dev` - Start development server (default: http://localhost:3000)
- `npm run build` or `pnpm build` - Build for production
- `npm run start` or `pnpm start` - Start production server
- `npm run lint` or `pnpm lint` - Run Next.js linting

### Testing Commands
- `npm test` or `pnpm test` - Run all tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage report
- `npx playwright test` - Run end-to-end tests (if configured)

### Code Quality Commands
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Run ESLint with auto-fix
- `npm run format` - Format code with Prettier
- `npx tsc --noEmit` - Run TypeScript type checking

### Database Commands (if applicable)
- `npm run db:migrate` or `pnpm db:migrate` - Run database migrations
- `npm run db:push` or `pnpm db:push` - Push schema to database
- `npm run db:studio` or `pnpm db:studio` - Open database studio
- `npm run db:types` or `pnpm db:types` - Generate database types

## Technology Stack

### Core
- **Framework**: Next.js (App Router)
- **Language**: TypeScript
- **Runtime**: Node.js
- **Package Manager**: npm or pnpm

### Frontend
- **Styling**: Tailwind CSS
- **UI Components**: shadcn/ui (Radix primitives)
- **State Management**: React hooks, Zustand, or server state with React Query
- **Forms**: React Hook Form + Zod validation

### Backend
- **API**: Next.js API Routes (Route Handlers)
- **Database**: PostgreSQL (via Supabase, Neon, or PlanetScale)
- **ORM**: Drizzle ORM or Prisma
- **Auth**: NextAuth.js (Auth.js) or Clerk

### Infrastructure
- **Deploy**: Vercel
- **Error Tracking**: Sentry
- **Analytics**: PostHog or Google Analytics
- **Email**: Resend or SendGrid

## Project Structure

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth route group (login, register)
│   ├── (main)/            # Main app route group (authenticated)
│   │   ├── dashboard/     # Dashboard page
│   │   └── [feature]/     # Feature pages
│   ├── api/               # API Route Handlers
│   │   ├── auth/          # Auth endpoints
│   │   ├── webhooks/      # Webhook handlers
│   │   └── [feature]/     # Feature endpoints
│   ├── globals.css        # Global styles
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Landing page
├── components/
│   ├── ui/                # shadcn/ui base components
│   ├── layout/            # Layout components (navbar, footer, sidebar)
│   └── features/          # Feature-specific components
├── db/                    # Database schema and connection
│   ├── index.ts           # Database client
│   ├── schema.ts          # Table definitions
│   └── migrations/        # Migration files
├── lib/                   # Shared utilities
│   ├── auth.ts            # Auth configuration
│   ├── utils.ts           # General utilities
│   └── validations.ts     # Zod schemas
├── hooks/                 # Custom React hooks
├── types/                 # TypeScript type definitions
├── config/                # App configuration
└── middleware.ts          # Next.js middleware (auth, redirects)
```

## Naming Conventions

- **Files**: Use kebab-case for file names (`user-profile.tsx`)
- **Components**: Use PascalCase for component names (`UserProfile`)
- **Functions**: Use camelCase for function names (`getUserData`)
- **Constants**: Use UPPER_SNAKE_CASE for constants (`API_BASE_URL`)
- **Types/Interfaces**: Use PascalCase (`UserData`, `ApiResponse`)
- **Route segments**: Use kebab-case for URL segments (`/user-settings`)

## TypeScript Guidelines

- Enable strict mode in `tsconfig.json`
- Use explicit types for function parameters and return values
- Prefer interfaces over types for object shapes
- Use union types for multiple possible values
- Avoid `any` type — use `unknown` when type is truly unknown
- Leverage utility types (`Partial`, `Pick`, `Omit`, etc.)

## Next.js Patterns

### Server vs Client Components
- Default to Server Components (no `"use client"` directive)
- Use Client Components only when needed: event handlers, hooks, browser APIs
- Keep client components small — push logic to server components
- Use `"use server"` for Server Actions

### Data Fetching
- Prefer Server Components for data fetching
- Use React Server Actions for mutations
- Implement proper loading states with `loading.tsx`
- Implement error boundaries with `error.tsx`
- Use `Suspense` for streaming

### Route Handlers (API)
- Use Route Handlers in `app/api/` for external API endpoints
- Prefer Server Actions for internal mutations
- Always validate input with Zod
- Return proper HTTP status codes
- Handle errors consistently

## Commit Conventions

Follow Conventional Commits format:
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`

Examples:
- `feat(auth): add Google OAuth login`
- `fix(dashboard): resolve data loading race condition`
- `refactor(api): extract validation middleware`

## Code Quality Standards

### ESLint
- Use Next.js recommended ESLint rules
- Enable React-specific and accessibility rules
- Configure import ordering rules

### Prettier
- 2 spaces indentation
- Single quotes for strings
- Trailing commas
- 100 character line length

### Testing
- Write unit tests for utilities and business logic
- Use integration tests for API routes
- Implement e2e tests for critical user flows (Playwright)
- Follow AAA pattern (Arrange, Act, Assert)

## Security Guidelines

- Validate all user inputs server-side with Zod
- Use HTTPS for all API calls
- Implement proper authentication and authorization
- Store sensitive data in environment variables
- Use Content Security Policy (CSP) headers
- Regularly audit dependencies with `npm audit`

## Performance Optimization

- Use code splitting with dynamic imports (`next/dynamic`)
- Optimize images with `next/image`
- Implement proper caching strategies
- Use React.memo, useMemo, useCallback where appropriate
- Analyze bundle size with `@next/bundle-analyzer`
- Use Suspense boundaries for streaming
