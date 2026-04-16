---
name: prd
description: 'Generate a Product Requirements Document (PRD) for a new feature. Use when planning a feature, starting a new project, or when asked to create a PRD. Triggers on: create a prd, write prd for, plan this feature, requirements for, spec out.'
user-invocable: true
---

# PRD Generator — MGM-Web (WhatsApp Group Metrics)

Create numbered, structured Product Requirements Documents for the MGM-Web dashboard platform.

---

## The Job

1. **Determine next PRD number**: Check `docs/prd/INDEX.md` for existing entries, find the highest number, increment by 1
2. Receive a feature description from the user
3. Ask 3-5 essential clarifying questions (with lettered options)
4. Generate a structured PRD based on answers
5. Save to `docs/prd/XX_nome-do-prd.md`
6. **Update `docs/prd/INDEX.md`**: Add new line in the PRDs table with status "Draft"

**Important:** Do NOT start implementing. Just create the PRD.

---

## Numbering Convention

PRDs are **sequentially numbered** with a two-digit prefix:

```
docs/prd/
├── 01_sentiment-improvements.md
├── 02_advanced-analytics.md
├── 03_member-engagement-score.md
└── ...
```

**Rules:**

- Always run `ls docs/prd/` first to find the last number
- Increment by 1: if last is `03_`, next is `04_`
- Use zero-padded two digits: `01`, `02`, ..., `09`, `10`
- Name in kebab-case after the number: `XX_feature-name.md`
- If `docs/prd/` doesn't exist, create it and start at `01`

**Task folders** (for future implementation tracking):

```
docs/tasks/
├── 01/    ← tasks from PRD 01
├── 02/    ← tasks from PRD 02
└── ...
```

Include this mapping in the PRD header so implementers know where to track work.

---

## Step 0: Pre-Research (Before Questions)

Before asking clarifying questions, **gather context** from the codebase:

1. **Check GitHub issue** (if referenced): `gh issue view NNN` — extract requirements, comments, linked PRs
2. **Check existing hooks/routes**: Search for hooks that reference endpoints that may not exist yet (ghost references)
   ```
   Grep for the feature domain in src/hooks/ to find existing client-side code
   ```
3. **Check `database.types.ts`**: Verify real column names for tables involved — Supabase columns may use unexpected naming (hyphens like `"uazapi-host"`, camelCase, or snake_case)
   ```
   Grep for the table name in src/lib/supabase/database.types.ts
   ```
4. **Check `package.json` scripts**: Use the correct verification command (currently `npm run fix` = lint + typecheck)
5. **Check `.claude/tasks/`**: Search for related session context files that may have prior investigation
   ```
   Grep for the feature keyword in .claude/tasks/context_session_*.md
   ```

This pre-research prevents writing PRDs with wrong field names, missing context, or ghost references.

---

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous. Focus on:

- **Problem/Goal:** What user or business problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Users & Permissions:** Which roles are affected? (Owner, Admin, Member)
- **Success Criteria:** How do we know it's done?

### Format Questions Like This:

```
1. What is the primary goal of this feature?
   A. Improve group monitoring and insights
   B. Enhance member engagement tracking
   C. Improve analytics and reporting
   D. Other: [please specify]

2. Which user roles are primarily affected?
   A. All roles (Owner, Admin, Member)
   B. Owner and Admin only
   C. Owner only
   D. All roles with different permission levels

3. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Backend only (API routes, Supabase queries)
   D. UI only (components, hooks)
```

This lets users respond with "1A, 2C, 3B" for quick iteration. Remember to indent the options.

---

## Step 2: PRD Structure

Generate the PRD with these sections:

### Header

```markdown
# PRD XX: Feature Name

> **PRD**: `docs/prd/XX_feature-name.md`
> **Tasks**: `docs/tasks/XX/`
> **Issue**: #NNN (if applicable)
> **Date**: YYYY-MM-DD
```

### 1. Introduction/Overview

Brief description of the feature and what user or business problem it solves.

### 2. Goals

Specific, measurable objectives (bullet list).

### 3. User Stories

Each story needs:

- **Title:** Short descriptive name
- **Description:** "As a [role], I want [feature] so that [benefit]"
- **Acceptance Criteria:** Verifiable checklist

Each story should be small enough to implement in one focused session.

**Format:**

```markdown
### US-001: [Title]

**Description:** As a [owner/admin/member], I want [feature] so that [benefit].

**Acceptance Criteria:**

- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] `npm run fix` passes (lint + typecheck)
- [ ] **[If UI]** Verify in browser at localhost:3003
- [ ] **[If Supabase]** Migration created and RLS policies defined
- [ ] **[If permissions]** OrgContext permission checks added
```

**Important:**

- Acceptance criteria must be verifiable, not vague. "Works correctly" is bad. "Button shows confirmation dialog before deleting group" is good.
- For UI stories: always include browser verification
- For data stories: always include migration + RLS criteria

### 4. Functional Requirements

Numbered list of specific functionalities:

- "FR-1: The system must allow owners to..."
- "FR-2: When a user clicks X, the system must..."

Be explicit and unambiguous.

### 5. Non-Goals (Out of Scope)

What this feature will NOT include. Critical for managing scope.

### 6. Architecture Considerations

Map affected layers using the project architecture:

```
Components    → src/components/{domain}/
UI Components → src/components/ui/ (shadcn/ui)
Hooks         → src/hooks/ (+ barrel export in index.ts)
API Routes    → src/app/api/{domain}/
Pages         → src/app/(dashboard)/{page}/
Types         → src/lib/types.ts (Zod schemas)
Auth          → src/lib/auth/ (getOrgContextFromCookies)
Supabase      → src/lib/supabase/ (clients, database.types.ts)
Services      → src/lib/services/
AI            → src/lib/ai/
Stores        → src/stores/ (Zustand)
```

Include:

- Which existing hooks/components to extend vs create new
- Supabase tables, RLS policies, or functions needed
- Permission checks needed (`canManageUsers`, `canCreateGroups`, `canViewAllGroups`)
- API routes to create or modify
- TanStack Query key conventions to follow

### 7. Success Metrics

How will success be measured from a user or business perspective?

### 8. Open Questions

Remaining questions or areas needing clarification.

---

## Writing for Implementers

The PRD reader may be a junior developer or AI agent. Therefore:

- Be explicit and unambiguous
- Reference specific files and hooks by path
- Use the project's permission hierarchy: Owner (level 1) > Admin (level 2) > Member (level 3)
- Number requirements for easy reference
- Use concrete examples with WhatsApp group context
- Reference `getOrgContextFromCookies()` for auth patterns
- Reference `org.organizationRootUserId` for group ownership queries

---

## Output

- **Format:** Markdown (`.md`)
- **Location:** `docs/prd/`
- **Filename:** `XX_feature-name.md` (zero-padded number + kebab-case)
- **Task folder:** `docs/tasks/XX/` (created when implementation begins)

---

## Example PRD

```markdown
# PRD 02: Group Health Score

> **PRD**: `docs/prd/02_group-health-score.md`
> **Tasks**: `docs/tasks/02/`
> **Issue**: #42
> **Date**: 2026-02-12

## Introduction

Add a composite "health score" to each WhatsApp group card, combining engagement rate, sentiment trends, and member activity into a single 0-100 metric. Currently, users must check multiple data points to understand group health, making it hard to quickly identify groups needing attention.

## Goals

- Provide a single, glanceable metric for overall group health
- Help users quickly identify underperforming groups
- Surface health trends over time (improving, declining, stable)
- Enable sorting/filtering groups by health score on the home page

## User Stories

### US-001: Display health score on group card

**Description:** As an owner, I want to see a health score on each group card so I can quickly identify which groups need attention.

**Acceptance Criteria:**

- [ ] Health score (0-100) displayed on GroupCard component
- [ ] Color coding: green (70-100), yellow (40-69), red (0-39)
- [ ] Trend indicator arrow (up/down/stable) based on 7-day comparison
- [ ] Score calculated from `statistics_daily` table (NOT `interactions`)
- [ ] API route returns score via `/api/groups` response
- [ ] `npm run fix` passes (lint + typecheck)
- [ ] Verify in browser at localhost:3003

### US-002: Sort groups by health score

**Description:** As an owner, I want to sort my groups by health score so I can prioritize which groups to focus on.

**Acceptance Criteria:**

- [ ] Sort option added to home page filters
- [ ] Default sort: lowest health score first (groups needing attention)
- [ ] Sort persists via URL params (using `useUrlFilters`)
- [ ] Works with infinite scroll pagination
- [ ] `npm run fix` passes (lint + typecheck)
- [ ] Verify in browser at localhost:3003

## Functional Requirements

- FR-1: Create `calculateHealthScore()` utility in `src/lib/analytics/health-score.ts`
- FR-2: Score formula: engagement (40%) + sentiment (30%) + activity (30%)
- FR-3: API route `/api/groups` includes `healthScore` and `healthTrend` in response
- FR-4: Use `statistics_daily` for all calculations (avoid `interactions` table)
- FR-5: GroupCard component displays score with color coding
- FR-6: Home page sort dropdown includes "Health Score" option
- FR-7: Score filtered by `group_owner = org.organizationRootUserId`

## Non-Goals

- No per-member health scores (group-level only)
- No custom weight configuration (fixed formula)
- No health score alerts (future PRD)
- No historical health score chart (future PRD)

## Architecture Considerations

| Layer     | Files                                                              |
| --------- | ------------------------------------------------------------------ |
| Utility   | `src/lib/analytics/health-score.ts` (new)                          |
| Types     | `src/lib/types.ts` (add HealthScore Zod schema)                    |
| API       | `src/app/api/groups/route.ts` (extend response with health score)  |
| Component | `src/components/groups/GroupCard.tsx` (add score display)           |
| Hook      | `src/hooks/useGroups.ts` (update return type)                      |
| Page      | `src/app/(dashboard)/section-home.tsx` (add sort option)           |
| Auth      | Uses existing `getOrgContextFromCookies()` pattern                 |

## Success Metrics

- Users can identify lowest-health groups within 3 seconds of loading home page
- Health score correlates with actual group engagement patterns
- No performance regression on home page load (< 2s)

## Open Questions

- Should health score update in real-time or on a daily batch?
- What's the minimum data threshold before showing a score? (e.g., 7 days of data)
```

---

## Index Management

**File:** `docs/prd/INDEX.md`

This is the single source of truth for all PRDs and their implementation status. It MUST be updated in these moments:

| Evento                 | Ação no INDEX.md                                                              |
| ---------------------- | ----------------------------------------------------------------------------- |
| PRD criado             | Adicionar linha com status "Draft" e progresso "0/N US"                       |
| PRD aprovado           | Mudar status para "Aprovado"                                                  |
| Implementação iniciada | Mudar status para "Em andamento", adicionar seção de detalhe com User Stories |
| User Story concluída   | Atualizar progresso (ex: "2/4 US"), marcar US como "Concluída" no detalhe     |
| Todas US concluídas    | Mudar status para "Concluído", remover seção de detalhe                       |
| PRD cancelado          | Mudar status para "Cancelado"                                                 |

---

## Checklist

Before saving the PRD:

- [ ] Checked `docs/prd/INDEX.md` to determine next number
- [ ] Asked clarifying questions with lettered options
- [ ] Incorporated user's answers
- [ ] Header includes PRD path, tasks folder, issue, and date
- [ ] User stories are small and specific
- [ ] Acceptance criteria include `npm run fix` (lint + typecheck), permissions, and Supabase where applicable
- [ ] Functional requirements are numbered and unambiguous
- [ ] Non-goals section defines clear boundaries
- [ ] Architecture section maps to project layers with file paths
- [ ] Saved to `docs/prd/XX_feature-name.md`
- [ ] **Updated `docs/prd/INDEX.md`** with new entry (status: Draft)
