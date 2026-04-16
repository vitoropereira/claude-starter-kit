---
name: ralph
description: 'Convert PRDs to prd.json for Ralph autonomous execution in MGM-Web. Use when you have an existing PRD and need to prepare it for a ralph-loop. Triggers on: convert this prd, turn this into ralph format, create prd.json from this, ralph json, prepare prd for ralph.'
user-invocable: true
---

# Ralph PRD Converter — MGM-Web

Converts existing PRDs from `docs/prd/` into `prd.json` format for autonomous execution via the `/ralph-loop` command.

---

## The Job

1. **Identify the PRD**: User provides PRD number or path. If not provided, read `docs/prd/INDEX.md` to list available PRDs.
2. **Read the PRD**: Parse `docs/prd/XX_feature-name.md`
3. **Check for existing task files**: If `docs/tasks/XX/` exists, use those for extra detail
4. **Convert to `prd.json`**: Save to project root as `prd.json`
5. **Suggest ralph-loop command**: Provide the `/ralph-loop` invocation

**Important:** Do NOT start implementing. Just create the prd.json.

---

## Output Format

```json
{
  "project": "MGM-Web",
  "prdNumber": "XX",
  "prdFile": "docs/prd/XX_feature-name.md",
  "tasksDir": "docs/tasks/XX/",
  "branchName": "feat/feature-name-kebab-case",
  "description": "[Feature description from PRD title/intro]",
  "userStories": [
    {
      "id": "US-001",
      "title": "[Story title]",
      "description": "As a [role], I want [feature] so that [benefit]",
      "taskFile": "docs/tasks/XX/US-001_title-kebab-case.md",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "`npm run fix` passes (lint + typecheck)"
      ],
      "filesToModify": [
        "src/components/groups/NewComponent.tsx",
        "src/hooks/useFeature.ts"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### Fields Explained

| Field           | Source                                                                   |
| --------------- | ------------------------------------------------------------------------ |
| `prdNumber`     | Extracted from PRD filename (`01`, `02`, etc.)                           |
| `prdFile`       | Path to the original PRD                                                 |
| `tasksDir`      | Path to task files directory                                             |
| `branchName`    | Derived from feature name using project conventions                      |
| `taskFile`      | Path to the corresponding task file in `docs/tasks/XX/`                  |
| `filesToModify` | Extracted from PRD's Architecture section or task's Implementation Notes |

### Branch Naming

Use project conventions — NOT `ralph/` prefix:

| Type        | Format                           | Example                        |
| ----------- | -------------------------------- | ------------------------------ |
| Feature     | `feat/feature-name`              | `feat/group-health-score`      |
| Fix         | `fix/bug-description`            | `fix/auth-org-repair`          |
| Improvement | `improvements/scope-description` | `improvements/analytics-perf`  |

---

## Story Size: The Number One Rule

**Each story must be completable in ONE ralph-loop iteration (one context window).**

Each iteration spawns a fresh Claude Code session with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories for MGM-Web:

- Add a new API route at `src/app/api/` with auth + Supabase query
- Create a React component using shadcn/ui and existing hooks
- Add a custom hook that calls an existing API route
- Add a Zod schema + types in `src/lib/types.ts`
- Add a sort/filter option to the home page group grid
- Create a Zustand store for a new feature

### Too big (split these):

- "Build the health score feature" → Split into: utility function, Zod schema, API route, hook, GroupCard UI, sort filter
- "Add member engagement tracking" → Split into: API route, hook, analytics component, detail panel
- "Refactor group detail page" → Split into one story per tab or section

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: MGM-Web Architecture Layers

Stories execute in priority order. Earlier stories must not depend on later ones. Follow the project's layer pattern:

**Correct order:**

1. Supabase changes (tables, RLS policies, functions)
2. Types (`src/lib/types.ts` — Zod schemas)
3. Services (`src/lib/services/`) — external API calls
4. API Routes (`src/app/api/`) — server-side logic
5. Hooks (`src/hooks/`) — client-side data fetching + barrel export
6. Components (`src/components/`) — UI
7. Pages (`src/app/(dashboard)/`) — page composition

**Wrong order:**

1. Component that uses a hook that doesn't exist yet
2. The hook

---

## Acceptance Criteria: Must Be Verifiable

Each criterion must be something that can be CHECKED programmatically or visually.

### Good criteria (verifiable):

- "API route `/api/groups` returns `healthScore` field in response"
- "GroupCard displays score badge with color: green (70-100), yellow (40-69), red (0-39)"
- "Sort dropdown includes 'Health Score' option on home page"
- "Query uses `statistics_daily` table, NOT `interactions`"
- "Data filtered by `group_owner = org.organizationRootUserId`"
- "`npm run fix` passes (lint + typecheck)"

### Bad criteria (vague):

- "Works correctly"
- "User can see the data easily"
- "Good UX"
- "Handles edge cases"

### Mandatory criteria for ALL stories:

```
"`npm run fix` passes (lint + typecheck)"
```

### Additional criteria by story type:

| Story Type                 | Additional Criteria                                           |
| -------------------------- | ------------------------------------------------------------- |
| **UI stories**             | "Verify in browser at localhost:3003"                         |
| **API route stories**      | "Auth via `getOrgContextFromCookies()`, returns 401 if null"  |
| **Hook stories**           | "Exported from `src/hooks/index.ts` barrel file"              |
| **Supabase stories**       | "RLS policies defined for the table"                          |
| **Type stories**           | "Zod schema in `src/lib/types.ts`, TS type inferred via `z.infer<>`" |
| **Analytics stories**      | "Uses `statistics_daily`, NOT `interactions` (3.6M+ rows)"   |

---

## Conversion Rules

1. **Read PRD first**: Always parse from `docs/prd/XX_feature-name.md`
2. **Check task files**: If `docs/tasks/XX/` exists, use task files for detailed implementation notes and `filesToModify`
3. **Each user story becomes one JSON entry**
4. **IDs**: Match PRD's US numbering (US-001, US-002, etc.)
5. **Priority**: Based on dependency order matching architecture layers
6. **All stories**: `passes: false` and empty `notes`
7. **Always add**: `npm run fix` criterion to every story
8. **Extract `filesToModify`**: From PRD's Architecture section or task's Implementation Notes
9. **Permission roles**: Use the hierarchy: Owner (level 1) > Admin (level 2) > Member (level 3)
10. **Auth pattern**: Always reference `getOrgContextFromCookies()` for API routes
11. **Group ownership**: Always filter by `group_owner = org.organizationRootUserId`

---

## Splitting Large Stories

If a PRD story is too big, split using letter suffixes (matching `/prd-tasks` convention):

**Original US-003 is too big → split into:**

```json
{
  "id": "US-003a",
  "title": "Health score API route",
  "taskFile": "docs/tasks/02/US-003a_health-score-api.md"
},
{
  "id": "US-003b",
  "title": "Health score GroupCard UI",
  "taskFile": "docs/tasks/02/US-003b_health-score-ui.md"
}
```

---

## Example

**Input:** `docs/prd/02_group-health-score.md`

**Output `prd.json`:**

```json
{
  "project": "MGM-Web",
  "prdNumber": "02",
  "prdFile": "docs/prd/02_group-health-score.md",
  "tasksDir": "docs/tasks/02/",
  "branchName": "feat/group-health-score",
  "description": "Group Health Score — Composite 0-100 metric combining engagement, sentiment, and activity",
  "userStories": [
    {
      "id": "US-001",
      "title": "Display health score on group card",
      "description": "As an owner, I want to see a health score on each group card so I can quickly identify which groups need attention.",
      "taskFile": "docs/tasks/02/US-001_display-health-score.md",
      "acceptanceCriteria": [
        "Health score (0-100) displayed on GroupCard component",
        "Color coding: green (70-100), yellow (40-69), red (0-39)",
        "Trend indicator arrow (up/down/stable) based on 7-day comparison",
        "Score calculated from `statistics_daily` table (NOT `interactions`)",
        "API route `/api/groups` returns `healthScore` and `healthTrend` in response",
        "Data filtered by `group_owner = org.organizationRootUserId`",
        "`npm run fix` passes (lint + typecheck)",
        "Verify in browser at localhost:3003"
      ],
      "filesToModify": [
        "src/lib/analytics/health-score.ts",
        "src/lib/types.ts",
        "src/app/api/groups/route.ts",
        "src/components/groups/GroupCard.tsx",
        "src/hooks/useGroups.ts",
        "src/hooks/index.ts"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Sort groups by health score",
      "description": "As an owner, I want to sort my groups by health score so I can prioritize which groups to focus on.",
      "taskFile": "docs/tasks/02/US-002_sort-by-health-score.md",
      "acceptanceCriteria": [
        "Sort option added to home page filters",
        "Default sort: lowest health score first",
        "Sort persists via URL params (using `useUrlFilters`)",
        "Works with infinite scroll pagination",
        "`npm run fix` passes (lint + typecheck)",
        "Verify in browser at localhost:3003"
      ],
      "filesToModify": [
        "src/app/(dashboard)/section-home.tsx",
        "src/app/api/groups/route.ts"
      ],
      "priority": 2,
      "passes": false,
      "notes": "Depends on US-001"
    }
  ]
}
```

---

## After Conversion: Suggest Ralph Loop

After saving `prd.json`, suggest the ralph-loop command:

```
/ralph-loop "You are implementing PRD 02: Group Health Score for MGM-Web. Read prd.json for the full spec. Work through user stories in priority order. For each story: read the task file, implement changes, run `npm run fix`. Mark the story as passes:true in prd.json when done. Output <promise>PRD 02 COMPLETE</promise> when all stories pass." --completion-promise "PRD 02 COMPLETE" --max-iterations 20
```

**Important:** Adjust `--max-iterations` based on number and complexity of stories (roughly 2-3 iterations per story).

---

## Handling Existing prd.json

Before writing a new `prd.json`, check if one already exists:

1. Read the current `prd.json` if it exists
2. If `prdNumber` differs from the new PRD:
   - Archive to `archive/YYYY-MM-DD-prd-XX-feature-name/prd.json`
   - Then write the new file
3. If same `prdNumber`: overwrite (re-conversion of same PRD)

---

## Checklist Before Saving

Before writing prd.json, verify:

- [ ] Read PRD from `docs/prd/XX_feature-name.md`
- [ ] Checked `docs/tasks/XX/` for additional implementation details
- [ ] **Previous prd.json archived** (if exists with different prdNumber)
- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories ordered by architecture layer (Supabase → types → services → API routes → hooks → components → pages)
- [ ] Every story has `npm run fix` criterion
- [ ] UI stories have "Verify in browser at localhost:3003"
- [ ] API route stories have auth via `getOrgContextFromCookies()`
- [ ] Analytics stories use `statistics_daily` (NOT `interactions`)
- [ ] Hook stories are exported from `src/hooks/index.ts` barrel file
- [ ] Type stories use Zod schema + `z.infer<>` pattern
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No story depends on a later story
- [ ] `filesToModify` populated for every story
- [ ] Ralph-loop command suggested with appropriate `--max-iterations`
