---
name: ralph-loop
description: 'Use when you have a prd-XX.json ready and want to autonomously implement all tasks in sequence within a Claude Code session. Triggers on: ralph-loop, execute prd, implement tasks, run ralph loop, start implementation loop, /ralph-loop.'
user-invocable: true
---

# Ralph Loop — In-Session PRD Executor

Reads `docs/prds/prd-XX.json` and implements tasks one by one in priority order within the current Claude Code session. Useful for 3-5 tasks or debugging specific tasks.

For full autonomous execution of an entire PRD, use `./scripts/ralph.sh XX` instead.

---

## Arguments

```
/ralph-loop <PRD_NUMBER> [--skip-to REQ-NNN] [--only REQ-NNN] [--retry-blocked]
```

| Argument | Required | Description |
|---|---|---|
| `PRD_NUMBER` | Yes | Which PRD to execute (e.g., `01`, `02`) |
| `--skip-to REQ-NNN` | No | Skip tasks before this ID |
| `--only REQ-NNN` | No | Execute only this specific task |
| `--retry-blocked` | No | Retry previously blocked tasks |

If no PRD number provided, list available prd-XX.json files.

---

## The Loop

```
FOR each task in prd-XX.json (sorted by priority, where status = "pending"):

  1. CHECK dependencies (skip if blocking task not yet passed)
  2. READ the task file (task.taskFile)
  3. READ all files listed in task.filesToModify (understand current state)
  4. IMPLEMENT the changes described in the task file
  5. RUN quality gates (defined in prd-XX.json qualityGates array)
  6. IF quality gates pass:
     - Update prd-XX.json: set task status = "passed", passes = true
     - Increment attempts
     - Add note with summary of what was done
     - Suggest git commit message
  7. IF quality gates fail:
     - Fix the errors
     - Re-run quality gates
     - If still failing after 3 attempts:
       - Revert changes: git checkout -- <only modified files>
       - Add error to task.notes, set status = "blocked"
       - Move to next task
  8. REPORT progress: [REQ-NNN] PASSED/BLOCKED
  9. CHECK: Are all tasks done? -> Output completion message

END FOR
```

---

## Step-by-Step Execution

### Step 0: Load Context

1. Read `docs/prds/prd-XX.json`
2. Count pending tasks (`status: "pending"`)
3. If zero pending -> report all done
4. Read the PRD file for overall context
5. Report status summary before starting

**Output:**
```
Reading prd-XX.json... PRD-XX: [Description]
N tasks pending, M passed, K blocked
```

### Step 1: Pick Next Task

1. Sort tasks by `priority` (ascending)
2. Find first task where `status === "pending"`
3. Check dependencies: all tasks in `dependsOn` must have `status === "passed"`
4. If dependency not met -> skip, report, try next
5. If `--only` specified -> jump to that task directly

### Step 2: Understand the Task

1. Read the task file at `task.taskFile`
2. Read EVERY file listed in `task.filesToModify` — understand current state before changing
3. Read acceptance criteria — these are your definition of done

### Step 3: Implement

1. Follow the task file's implementation notes and suggested approach sections
2. Create or modify files as described
3. Follow "Key patterns to follow" section

**Project-Specific Rules:**
<!-- CUSTOMIZE: Add your project-specific rules here. Examples: -->
<!-- - Auth: Use your auth pattern (e.g., `getServerSession()`, `supabase.auth.getUser()`, etc.) -->
<!-- - State: Use your state management approach (e.g., React Context, Redux, Zustand, etc.) -->
<!-- - Imports: Use your import conventions (e.g., `@/*` path alias, relative imports, etc.) -->
<!-- - DB client: Use appropriate client type per your project conventions -->
<!-- - Dev server: Your dev server URL -->
<!-- - i18n: Your translation file locations -->
- Follow patterns documented in your project's CLAUDE.md
- Do NOT modify files outside the task's scope
- Do NOT add unnecessary comments, docstrings, or TODOs
- Do NOT over-engineer — implement exactly what is asked

### Step 4: Quality Gates

Run the commands from the `qualityGates` array in `prd-XX.json`, in order.

If any gate fails:
1. Read the error output carefully
2. Fix the specific errors
3. Re-run the failing gate
4. Max 3 fix attempts per task

### Step 5: Update prd-XX.json

On success:
```json
{
  "status": "passed",
  "passes": true,
  "attempts": 1,
  "notes": "Implemented: [brief summary]. Quality gates passed."
}
```

On failure (after 3 attempts):
```json
{
  "status": "blocked",
  "passes": false,
  "attempts": 3,
  "notes": "BLOCKED: [error description]. Manual intervention needed."
}
```

### Step 6: Git Commit (suggest, don't auto-commit)

After each passed task, suggest the commit:

```
Ready to commit. Suggested command:
  git add -A && git commit -m "feat(prd-XX): REQ-NNN - [title]"
```

Wait for user confirmation before committing (unlike ralph.sh which auto-commits).

### Step 7: Next or Done

- If more tasks remain -> go to Step 1
- If all tasks passed -> report completion
- If task was blocked -> continue to next task (don't stop the loop)

---

## Progress Reporting

After each task completion:
```
[REQ-NNN] PASSED - Title (N/M tasks complete)
```

After each failure:
```
[REQ-NNN] BLOCKED - Title - Reason
```

At session end:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD-XX Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Passed:  N/M
 Pending: X/M
 Blocked: Y/M

[If all passed]: PRD-XX COMPLETE!
[If blocked]: Blocked tasks need manual intervention:
  - REQ-NNN: [reason]
```

---

## Special Task Types

### SQL Migration Tasks

- Create the migration file as described
- Verify file exists with expected content (grep for table/column names)
- Mark as passed — user executes SQL manually
- Add note: "Migration file created. User must apply via project's migration tool."

### i18n Tasks

- Add translations to ALL required locale directories
- Verify translation keys match between languages
- Use existing translation patterns from the codebase

### SEO/Metadata Tasks

- Use your framework's metadata approach (e.g., `generateMetadata` in Next.js, `<Helmet>` in React, etc.)
- Verify with explanation of what tags will appear in `<head>`
- Follow existing metadata patterns in the codebase

---

## Error Recovery

| Error | Action |
|---|---|
| Quality gate (lint) fails | Read error, fix lint/format issues, retry |
| Quality gate (build/types) fails | Read errors, fix imports/types, retry |
| File not found in filesToModify | Check if dependency task needs to run first |
| Task file missing | Skip task, set status = "blocked" |
| prd-XX.json malformed | Stop, report to user |
| Dependency not passed | Skip task, report which dependency blocks it |

---

## Example Session

```
Reading prd-01.json... PRD-01: Critical Fixes
10 tasks pending, 0 passed, 0 blocked

--- Task 1/10: REQ-001 (priority 1) ---
Reading: docs/tasks/01/REQ-001_checkout-session-auth.md
Reading: src/api/stripe/create-checkout-session/route.ts
Implementing auth fix...
Running quality gates... PASSED
Updating prd-01.json...
[REQ-001] PASSED - Checkout Session Authentication (1/10)

Ready to commit:
  git add -A && git commit -m "feat(prd-01): REQ-001 - Checkout Session Authentication"

--- Task 2/10: REQ-002 (priority 2) ---
Reading: docs/tasks/01/REQ-002_cron-secret-authorization.md
...

--- Task 7/10: REQ-006b (priority 7) ---
Checking dependencies: REQ-006a... PASSED
Reading: docs/tasks/01/REQ-006b_remove-metatags-component.md
...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PRD-01 Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Passed:  9/10
 Pending: 0/10
 Blocked: 1/10

Blocked tasks:
  - REQ-009: type-check fails on unrelated import
```

---

## Checklist (Internal — verify before marking task as passed)

- [ ] Task file was read completely
- [ ] All `filesToModify` were read BEFORE making changes
- [ ] Implementation follows task's "Key patterns to follow" section
- [ ] All quality gates pass with zero errors
- [ ] prd-XX.json updated with correct status and notes
- [ ] No files outside task scope were modified
- [ ] Git commit suggested to user
