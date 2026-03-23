# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Note**: This is a generic template from claude-starter-kit. Customize it for your project.

## Available Slash Commands

| Command | Description |
|---------|-------------|
| `/commit` | Stage all changes and create commit with AI-generated message |
| `/push` | Push current branch to remote |
| `/pr` | Create Pull Request on GitHub |
| `/ship` | Commit + Push + PR in one command |

## Domain Skills

| Skill | When to Use |
|-------|-------------|
| `/seo-technical` | SEO for Next.js (sitemaps, meta tags, JSON-LD, Open Graph) |
| `/stripe` | Payments, checkout sessions, subscriptions, webhooks |
| `/ux-design` | UX Design principles for styling interface |
| `/marketing-copy` | Copywriting for landing page and marketing content |
| `/favicon` | Favicon and app icon generation |

## Development Skills

| Skill | When to Use |
|-------|-------------|
| `/nextjs-best-practices` | Server vs Client Components, data fetching, App Router patterns |
| `/nextjs-supabase-auth` | Supabase Auth + Next.js App Router integration |
| `/supabase-postgres-best-practices` | Query performance, RLS, connection pooling, schema design |
| `/testing-patterns` | Factory functions, mocking strategies, TDD workflow |
| `/clean-code` | SRP, DRY, KISS, guard clauses, naming conventions |
| `/performance` | Core Web Vitals, image optimization, Lighthouse scores |

## PRD Workflow Skills

| Skill | When to Use |
|-------|-------------|
| `/prd` | Generate a PRD from a feature idea |
| `/prd-tasks` | Break a PRD into individual task files |
| `/ralph` | Convert PRD + tasks into prd-XX.json for execution |
| `/ralph-loop` | Implement tasks in-session from prd-XX.json |

### AFK Execution (standalone terminal)

```bash
./scripts/ralph-setup.sh 01   # Create branch, validate build
./scripts/ralph.sh 01 20      # Run up to 20 iterations
```

## Security Skills

| Skill | When to Use |
|-------|-------------|
| `/security-best-practices` | Next.js + React security review (OWASP, CSP, XSS) |

## Specialized Agents

| Agent | Purpose |
|-------|---------|
| `security-auditor` | Security audit for APIs, Supabase RLS, Stripe webhooks, auth flows |

Invoke via `Task` tool with `subagent_type: "agent-name"`
