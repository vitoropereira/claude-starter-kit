---
name: prd-tasks
description: "Generate task files from an existing PRD. Use when a PRD is approved and ready for implementation, when you need to break a PRD into trackable task files."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
user-invocable: true
---

# PRD Task Generator

Read an existing PRD from `docs/prds/` and generate individual task files in `docs/tasks/XX/`, one per requirement.

---

## The Job

1. **Identify the PRD**: User provides PRD number or file path. If not provided, read `docs/prds/INDEX.md` to list available PRDs.
2. **Read the PRD**: Parse `docs/prds/PRD-XX-feature-name.md`
3. **Pre-research**: Verify real schemas, hooks, and prior context (see Step 0 below)
4. **Extract Requirements**: Each `REQ-XXX` becomes one task file
5. **Create task folder**: `docs/tasks/XX/` (matching the PRD number)
6. **Generate task files**: One `.md` per requirement
7. **Update INDEX.md**: Set PRD status to "In Progress", add detail section with REQ table

**Important:** Do NOT start implementing. Just create the task files.

---

## Step 0: Pre-Research (Before Generating Tasks)

Before writing any task file, **verify real data** from the codebase:

1. **Check existing types/schemas**: Verify real field names for any data structures mentioned in the PRD
2. **Check existing hooks/services**: Look for code that already references API routes — some may call endpoints that don't exist yet (ghost references). Document these.
3. **Check existing routes**: Verify which routes exist vs. need to be created
4. **Check for prior context**: Search for related files that may have prior investigation on the feature

This pre-research prevents writing tasks with wrong field names, missing context, or referencing non-existent code.

---

## Task File Format

Each task file follows this structure:

**Filename:** `docs/tasks/XX/US-NNN_title-kebab-case.md`

```markdown
# US-NNN: Title

> **PRD**: `docs/prd/XX_feature-name.md`
> **Task**: `docs/tasks/XX/US-NNN_title-kebab-case.md`
> **Status**: Pending

## Description

As a [role], I want [feature] so that [benefit].

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Build/lint passes

## Implementation Notes

### Files to modify/create

- `path/to/component.tsx` — description
- `path/to/hook.ts` — description

### Current code structure (reference)

Include relevant code snippets from the current codebase so the implementer
knows the exact function signatures, variable names, and patterns to follow.

### New code structure

Show the target code structure so the implementer knows what to build.

### Key patterns to follow

- Pattern 1 from existing codebase
- Pattern 2 from existing codebase

### Dependencies

- Depends on: US-NNN (if applicable)
- Blocks: US-NNN (if applicable)

## Testing

- [ ] Manual test: description
- [ ] Verify in browser
```

---

## Rules

### Ordering and Dependencies

- Extract dependency order from the PRD's Functional Requirements
- Schema/types first, then API routes, then hooks, then UI
- Mark dependencies explicitly in each task file

### Implementation Notes

For each task, analyze the PRD's Architecture section and add:

- **Specific file paths** to modify or create
- **Which existing components/hooks** to extend
- **Database changes** needed (if applicable)
- **Permission checks** if applicable

This is what makes the tasks actionable — a developer or AI agent should know exactly where to start.

### Task Sizing

Each task must fit in **one context window** without compression. Guidelines:

- **Max 3 files** to modify/create per task
- **~80 lines** of new code per task
- If a task touches both API route + hook + UI component, it's too big — split it

If a User Story is too large, split it:

```
# Original US-003 is too big -> split into:
docs/tasks/02/US-003a_feature-api.md
docs/tasks/02/US-003b_feature-ui.md
```

Use letter suffixes (a, b, c) to keep the numbering aligned with the PRD.

### Include Real Code References

When a task involves existing code, **include the actual current code** in the task file. This prevents the implementer from guessing patterns.

### Flag Ghost References

If pre-research reveals code calling an API route that doesn't exist yet, **document it explicitly**:

```markdown
### Ghost reference
The hook `useDeleteItems` already calls `POST /api/items/delete`,
but this route does not exist yet. This task creates it.
```

---

## INDEX.md Update

After generating tasks, update `docs/prds/INDEX.md`:

1. **Change PRD status** from "Draft" or "Approved" to "In Progress"
2. **Update progress**: "0/N US"
3. **Add detail section** below the table:

```markdown
---

## PRD XX: Feature Name

| US     | Title          | Status  | Branch/PR |
| ------ | -------------- | ------- | --------- |
| US-001 | Title from PRD | Pending | -         |
| US-002 | Title from PRD | Pending | -         |
```

---

## Splitting Large Stories

If a PRD story is too big, split using letter suffixes:

**Original US-003 is too big -> split into:**

```json
{
  "id": "US-003a",
  "title": "Feature API route",
  "taskFile": "docs/tasks/02/US-003a_feature-api.md"
},
{
  "id": "US-003b",
  "title": "Feature UI",
  "taskFile": "docs/tasks/02/US-003b_feature-ui.md"
}
```

---

## Updating Task Status

When working on implementation, update task files:

1. **Starting a task**: Change status to `In Progress` in task file header and INDEX.md
2. **Completing a task**: Check all acceptance criteria boxes, change status to `Completed`, update INDEX.md progress
3. **All tasks done**: Update INDEX.md PRD status to "Completed"

---

## Checklist

Before finishing task generation:

- [ ] Read the PRD completely
- [ ] **Pre-research**: Verified field names and code patterns
- [ ] **Pre-research**: Checked for ghost references (calls to non-existent routes)
- [ ] Created `docs/tasks/XX/` folder
- [ ] One task file per User Story (with letter splits if needed)
- [ ] Each task has max 3 files, ~80 lines new code (fits in one context window)
- [ ] Each task has implementation notes with specific file paths
- [ ] Each task includes "Current code structure" with relevant code snippets
- [ ] Each task includes "Key patterns to follow" section
- [ ] Acceptance criteria include project build/lint verification commands
- [ ] Dependencies marked between tasks
- [ ] Testing section with manual test steps
- [ ] Updated `docs/prds/INDEX.md` with status and detail section
