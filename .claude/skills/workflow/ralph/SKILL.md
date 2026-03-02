---
name: ralph
description: 'Convert PRDs to prd-XX.json for Ralph autonomous execution. Use when you have an existing PRD and need to prepare it for ralph.sh or /ralph-loop. Triggers on: convert this prd, turn this into ralph format, create prd json, ralph json, prepare prd for ralph, /ralph.'
user-invocable: true
---

# Ralph PRD Converter

Converts existing PRDs from `docs/prds/` into `docs/prds/prd-XX.json` format for autonomous execution via `./ralph.sh` or `/ralph-loop`.

---

## The Job

1. **Identify the PRD**: User provides PRD number (e.g., `/ralph 01`). If not provided, list available PRDs from `docs/prds/`.
2. **Read the PRD**: Parse `docs/prds/PRD-XX-name.md`
3. **Check for task files**: Read all files in `docs/tasks/XX/` for implementation details
4. **Convert to prd-XX.json**: Save to `docs/prds/prd-XX.json`
5. **Suggest next step**: Provide the `./ralph.sh XX` invocation

**Important:** Do NOT start implementing. Just create the prd-XX.json.

---

## Output Format

```json
{
  "project": "<PROJECT_NAME>",
  "prdNumber": "XX",
  "prdFile": "docs/prds/PRD-XX-name.md",
  "tasksDir": "docs/tasks/XX/",
  "branchName": "fix/prd-XX-name-kebab-case",
  "description": "[Description from PRD title/intro]",
  "qualityGates": ["npm run lint", "npm run build"],
  "tasks": [
    {
      "id": "REQ-001",
      "title": "[Task title]",
      "taskFile": "docs/tasks/XX/REQ-001_title-kebab-case.md",
      "acceptanceCriteria": [
        "Criterion 1",
        "Criterion 2",
        "Lint/build passes"
      ],
      "filesToModify": [
        "src/api/route.ts",
        "src/components/feature.tsx"
      ],
      "priority": 1,
      "dependsOn": [],
      "status": "pending",
      "passes": false,
      "attempts": 0,
      "notes": ""
    }
  ]
}
```

### Fields Explained

| Field | Source |
|---|---|
| `project` | Your project name |
| `prdNumber` | Extracted from PRD filename (`01`, `02`, etc.) |
| `prdFile` | Path to the original PRD |
| `tasksDir` | Path to task files directory |
| `branchName` | Derived from PRD name using project conventions |
| `qualityGates` | Your project's build/lint commands (customize per project) |
| `taskFile` | Path to the corresponding task file in `docs/tasks/XX/` |
| `filesToModify` | Extracted from task file's "Files to modify/create" section |
| `dependsOn` | Array of REQ IDs this task depends on (e.g., `["REQ-006a"]`) |

### Branch Naming

Use project conventions:

| Type | Format | Example |
|---|---|---|
| Critical fixes | `fix/prd-XX-description` | `fix/prd-01-critical-fixes` |
| Performance | `perf/prd-XX-description` | `perf/prd-02-performance-bundle` |
| Security | `security/prd-XX-description` | `security/prd-03-security-hardening` |
| SEO | `seo/prd-XX-description` | `seo/prd-04-seo-metadata` |
| Accessibility | `a11y/prd-XX-description` | `a11y/prd-05-accessibility` |
| Database | `db/prd-XX-description` | `db/prd-06-database-changes` |
| Frontend | `feat/prd-XX-description` | `feat/prd-07-frontend-ux` |
| i18n | `i18n/prd-XX-description` | `i18n/prd-08-internationalization` |

---

## Task Size: The Number One Rule

**Each task must be completable in ONE claude -p invocation (one context window).**

Each invocation spawns a fresh Claude session with no memory of previous tasks. If a task is too big, the LLM runs out of context before finishing.

### Right-sized tasks:

- Fix a single API route to use proper authentication
- Add metadata to a specific page
- Create a single migration file
- Fix a database query to use correct operators
- Add a sanitization step to a processing pipeline
- Internationalize one component

### Too big (split these):

- "Fix all API routes" -> Split into one task per route
- "Add metadata to all pages" -> Split into groups of 2-3 pages max
- "Internationalize the entire sidebar" -> Split by section

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Task Ordering: Architecture Layers

Tasks execute in priority order. Earlier tasks must not depend on later ones.

**Correct order:**

1. Database migrations / schema changes
2. Type definitions / interfaces
3. Database access functions / ORM models
4. Library / utility functions
5. API Routes / server actions
6. Hooks / state management
7. Components
8. Pages / views

---

## Acceptance Criteria: Must Be Verifiable

Each criterion must be something that can be CHECKED programmatically or visually.

### Good criteria (verifiable):

- "Request without valid session returns 401"
- "Sanitizer configured after raw HTML parser in plugin pipeline"
- "Query uses correct operator for array filtering"
- "Lint passes"
- "Build passes"

### Bad criteria (vague):

- "Works correctly"
- "User can see the data easily"
- "Good UX"

### Mandatory criteria for ALL tasks:

Your project's quality gate commands must always be included. For example:
```
"Lint passes"
"Build passes"
```

### Additional criteria by task type:

| Task Type | Additional Criteria |
|---|---|
| **UI tasks** | "Verify in browser at dev server URL" |
| **API route tasks** | "Auth check returns 401 if no valid session" |
| **Migration tasks** | "SQL file follows project conventions" |
| **i18n tasks** | "Translations added to all required locale directories" |
| **SEO tasks** | "Verify meta tags with curl or DevTools" |

---

## Conversion Rules

1. **Read PRD first**: Always parse from `docs/prds/PRD-XX-name.md`
2. **Read ALL task files**: Parse every file in `docs/tasks/XX/` for detailed implementation notes
3. **Each task file becomes one JSON entry**
4. **IDs**: Match task file naming (REQ-001, REQ-002, REQ-006a, REQ-006b, etc.)
5. **Priority**: Based on the PRD's execution order section, or infer from architecture layers
6. **Dependencies**: Extract from task file's "Dependencies" section (e.g., REQ-006b depends on REQ-006a)
7. **All tasks start with**: `status: "pending"`, `passes: false`, `attempts: 0`, empty `notes`
8. **Always add**: Your project's quality gate commands as criteria to every task
9. **Extract filesToModify**: From task file's "Files to modify/create" section
10. **Follow project-specific patterns**: Check CLAUDE.md for auth patterns, state management, import conventions, etc.

---

## Detecting Dependencies

Look for these patterns in task files:

- **Explicit**: "Depends on: REQ-006a" in the Dependencies section
- **Implicit**: Task B references files created by task A
- **Letter suffixes**: REQ-006a and REQ-006b are usually sequential (b depends on a)

---

## Example

**Input:** `/ralph 01`

**Reads:** `docs/prds/PRD-01-critical-fixes.md` + all files in `docs/tasks/01/`

**Output `docs/prds/prd-01.json`:**

```json
{
  "project": "MyProject",
  "prdNumber": "01",
  "prdFile": "docs/prds/PRD-01-critical-fixes.md",
  "tasksDir": "docs/tasks/01/",
  "branchName": "fix/prd-01-critical-fixes",
  "description": "Critical Fixes - Security, subscription bugs, SEO and performance",
  "qualityGates": ["npm run lint", "npm run build"],
  "tasks": [
    {
      "id": "REQ-001",
      "title": "Checkout Session Authentication",
      "taskFile": "docs/tasks/01/REQ-001_checkout-session-auth.md",
      "acceptanceCriteria": [
        "Request without valid session returns 401",
        "userId and email extracted from session token, not from body",
        "Request with user A session cannot create checkout for user B",
        "Lint passes",
        "Build passes"
      ],
      "filesToModify": [
        "src/api/stripe/create-checkout-session/route.ts"
      ],
      "priority": 1,
      "dependsOn": [],
      "status": "pending",
      "passes": false,
      "attempts": 0,
      "notes": ""
    }
  ]
}
```

---

## After Conversion: Suggest Next Steps

After saving `docs/prds/prd-XX.json`, output:

```
prd-XX.json created with N tasks.

To preview execution plan:
  ./scripts/ralph.sh XX --dry-run

To execute:
  ./scripts/ralph.sh XX

To run interactively in this session:
  /ralph-loop XX
```

---

## Checklist Before Saving

Before writing prd-XX.json, verify:

- [ ] Read PRD from `docs/prds/PRD-XX-name.md`
- [ ] Read ALL task files in `docs/tasks/XX/`
- [ ] Each task is completable in one context window (small enough)
- [ ] Tasks ordered by architecture layer (DB -> types -> models -> lib -> API -> hooks -> components -> pages)
- [ ] Every task has project quality gate criteria
- [ ] UI tasks have "Verify in browser at dev server URL"
- [ ] API route tasks have auth verification criteria
- [ ] i18n tasks have translation file criteria
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No task depends on a later task
- [ ] `filesToModify` populated for every task
- [ ] Dependencies extracted from task files (especially letter-suffixed tasks like REQ-006a/b)
- [ ] `qualityGates` set to your project's build/lint commands
