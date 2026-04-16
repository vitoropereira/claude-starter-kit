# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A consolidated starter kit of reusable Claude Code assets (commands, skills, agents, templates, hooks, settings, MCP configs, scripts, prompts). Sourced from 20+ projects. Not an application — nothing to build, test, or run. Users copy what they need into their own projects.

## Repository Structure

```
.claude/
  commands/       # Slash commands: commit, push, pr, ship
  agents/         # Specialized subagents (security-auditor)
  skills/         # ~160 skill directories (domain knowledge packs) + some "copy" duplicates pending cleanup
templates/        # Stack-specific CLAUDE.md templates (nextjs, vue, python, php, node-express, common)
scripts/          # Ralph autonomous execution scripts (ralph.sh, ralph-setup.sh, ralph-queue.sh)
settings/         # Pre-configured settings.local.json files (minimal, nextjs, vue)
hooks/            # Hook configs (auto-prettier, terminal-notifications, auto-format-php)
mcp/              # MCP server configs (common, javascript, python)
prompts/          # Audit and bootstrap prompts
docs/             # Distribution planning notes
```

## Key Workflows

### Slash Commands

| Command | Purpose |
|---------|---------|
| `/commit` | Stage all + commit with AI message + Co-Authored-By trailer |
| `/push` | Push with upstream verification |
| `/pr` | Create GitHub PR via `gh` CLI |
| `/ship` | Commit + push + PR in one step |

### Ralph (Autonomous PRD Execution)

```
Idea → /prd → /prd-tasks → /ralph → ralph-setup.sh → ralph.sh → PR
```

- `/prd` generates a numbered PRD with user stories
- `/prd-tasks` breaks it into task files
- `/ralph` converts to `prd-XX.json`
- `./scripts/ralph-setup.sh XX` creates branch + validates build
- `./scripts/ralph.sh XX 20` runs up to 20 autonomous iterations
- `/ralph-loop XX` executes in-session instead

## Content Origins and Licensing

Some skills have third-party origins requiring attribution:

| Content | Source | License |
|---------|--------|---------|
| `supabase-postgres-best-practices/` | Supabase official | MIT — keep attribution |
| `security-best-practices/` | Credited to OpenAI | Needs verification |
| Several skills | tinyplate/claude-code-templates (Daniel Avila) | Needs verification |

## Working in This Repo

- Language is Portuguese (Brazilian) for user-facing docs; skills themselves are English
- The `.claude/CLAUDE.md` is a generic template meant to be copied into target projects — not specific to this repo
- The kit has a Next.js + Supabase + Stripe bias; `docs/DISTRIBUTION_PLAN.md` outlines plans to reorganize into `core/` + `packs/`
- When adding new skills, place them as `.claude/skills/<skill-name>/SKILL.md`
- When adding new commands, place them as `.claude/commands/<name>.md` with YAML frontmatter (name, description, allowed-tools)
- `.claude/settings.local.json` contains accumulated permissions from a prior project (Calvino) — not meaningful for this repo
- Several skill directories have " copy" suffix duplicates (e.g., `case-study-builder copy/`) that need deduplication
- Files like `CHANGELOG copy.md`, `README copy.md`, `SKILL-MODE-PATTERN copy.md` in `.claude/skills/` are also duplicates pending cleanup
