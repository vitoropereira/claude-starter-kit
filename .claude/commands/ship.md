---
name: ship
description: "Commit, push, and create a PR in one command"
allowed-tools: Bash, Read, Edit, Glob, Grep
---

# Ship Command

Commit all changes, push to remote, and create a pull request in one go.

## Instructions

### Step 1: Gather Context

Run these commands in parallel:
- `git status` - check current state (do NOT use -uall flag)
- `git diff` - see unstaged changes
- `git diff --cached` - see staged changes
- `git branch --show-current` - get current branch name
- `git log --oneline -5` - see recent commit style

### Step 2: Verify & Update Documentation

Before committing, check if the changes require documentation updates. Analyze the diff from Step 1 and:

**2a. PRD task status** — If changes implement a PRD user story:
- Find the PRD file in `docs/prd/` (check branch name or commit messages for PRD number)
- Update acceptance criteria from `- [ ]` to `- [x]` for completed items
- If all AC for a US are done, mark the US as complete

**2b. CLAUDE.md files** — If changes introduce new patterns:
- New API route → check if `src/app/api/CLAUDE.md` or root `CLAUDE.md` needs the route listed
- New hook → check if root `CLAUDE.md` hooks section lists it
- New component → check if root `CLAUDE.md` component structure section mentions it
- Changed auth pattern → check if `src/lib/auth/CLAUDE.md` needs updating

**2c. Session context** — If a session context file exists in `.claude/tasks/`:
- Update with what was accomplished in this session

**Rules:**
- Only update docs that are DIRECTLY related to the code changes
- Do NOT create new documentation files unless explicitly needed
- Keep updates minimal and factual — no fluff
- If no docs need updating, skip this step entirely and say "No doc updates needed"

### Step 3: Commit Changes

1. If there are changes to commit:
   - Analyze all changes (including doc updates from Step 2) and draft a commit message
   - Use imperative mood, be concise, focus on "why"
   - Stage all changes with `git add -A` (but NOT files in .gitignore)
   - Create the commit:

```bash
git commit -m "$(cat <<'EOF'
Your commit message here

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

2. If no changes exist, skip to Step 4

### Step 4: Push to Remote

1. Check if branch tracks a remote with `git branch -vv`
2. Push the branch:

```bash
# If no upstream
git push -u origin HEAD

# If already tracking
git push
```

### Step 5: Create Pull Request

1. Get the full diff from base branch:
```bash
git log origin/main..HEAD --oneline
git diff origin/main...HEAD --stat
```

2. Analyze ALL commits that will be in the PR

3. Create the PR **always targeting `main`**:

```bash
gh pr create --base main --title "Your PR title" --body "$(cat <<'EOF'
## Summary
- Brief description of changes
- What problem this solves

## Test plan
- [ ] How to test these changes
- [ ] What to verify

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)"
```

4. Return the PR URL to the user

## Important

- Do NOT commit files containing secrets (.env, credentials, API keys)
- If pre-commit hooks fail, fix issues and create a NEW commit
- Never use `git push --force`
- If a PR already exists for the branch, inform the user and provide the URL
- If on master/main branch, warn the user and ask if they want to create a feature branch first
