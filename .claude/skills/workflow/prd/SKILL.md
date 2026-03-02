---
name: prd
description: "Generate a Product Requirements Document (PRD) for a new feature. Use when planning a feature, starting a new project, or when asked to create a PRD."
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
user-invocable: true
---

# PRD Generator

Create a structured Product Requirements Document from a feature idea.

---

## The Job

1. **Gather the idea**: User provides feature description, or ask them
2. **Explore the codebase**: Understand current architecture and patterns
3. **Write the PRD**: Save to `docs/prds/PRD-XX-feature-name.md`
4. **Update INDEX.md**: Add to PRD index

**Important:** Do NOT start implementing. Just create the PRD.

---

## PRD Format

Save to `docs/prds/PRD-XX-feature-name.md`:

```markdown
# PRD #XX — Feature Name

## Problem
What problem does this solve? Who has this problem?

## Objective
What outcome do we want?

## Target Audience
Who benefits from this feature?

## Functional Requirements

### RF-01: Requirement Name
- Detailed description
- Desktop behavior
- Mobile behavior

### RF-02: Requirement Name
- Detailed description

## Non-Functional Requirements
- Performance expectations
- Responsiveness
- Accessibility
- i18n / l10n

## Components Affected
- `path/to/component.tsx` — what changes
- `path/to/file.ts` — what changes

## User Stories

### US-001: Story Title
As a [role], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Build/lint passes

### US-002: Story Title
...

## Success Metrics
- Metric 1
- Metric 2

## Effort Estimate
**Small/Medium/Large** — brief justification

## Priority
**P0/P1/P2** — impact vs effort reasoning
```

---

## INDEX.md

Maintain `docs/prds/INDEX.md`:

```markdown
# PRD Index

| # | Feature | Issue | Status | Progress |
|---|---------|-------|--------|----------|
| 01 | [Feature Name](01_feature-name.md) | #N | Draft | — |
| 02 | [Feature Name](02_feature-name.md) | #N | Approved | 0/3 US |
```

**Statuses:** Draft, Approved, In Progress, Completed

---

## Numbering

- Check `docs/prds/INDEX.md` for the next available number
- If no INDEX.md exists, start at `01`
- Zero-pad to 2 digits: `01`, `02`, ... `10`, `11`

---

## Rules

1. Each user story must be small enough for one context window
2. Order stories by architecture layer (DB -> types -> API -> hooks -> UI)
3. Include specific file paths in Components Affected
4. Acceptance criteria must be verifiable
5. Always include your project's build/lint verification commands as criteria (e.g., `npm run lint`, `npm run build`, `npm run type-check`)
