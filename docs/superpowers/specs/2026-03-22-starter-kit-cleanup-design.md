# Starter Kit Cleanup + Install Script

**Date:** 2026-03-22
**Status:** Approved

## Goal

Organize the claude-starter-kit so it works as a reusable source of Claude Code assets (skills, commands, agents) that can be copied into any project via a single script. When skills are updated here, re-running the script propagates changes by overwriting.

## User Workflow

1. Edit/add skills, commands, agents in this repo
2. Run `./install.sh /path/to/project` to copy to target project
3. In the target project, ask Claude to adapt irrelevant skills

## Changes

### 1. Delete 27 duplicate "copy" items

All verified byte-for-byte identical to originals.

**23 directories:**
case-study-builder copy, cold-outreach-sequence copy, content-idea-generator copy, daily-briefing-builder copy, de-ai-ify copy, go-mode copy, homepage-audit copy, last30days copy, linkedin-authority-builder copy, linkedin-profile-optimizer copy, marketing-principles copy, meeting-prep copy, newsletter-creation-curation copy, plan-my-day copy, positioning-basics copy, reddit-insights copy, scripts copy, social-card-gen copy, testimonial-collector copy, tweet-draft-reviewer copy, vault-cleanup-auditor copy, voice-extractor copy, youtube-summarizer copy

**4 files:**
CHANGELOG copy.md, README copy.md, SKILL-MODE-PATTERN copy.md, skills-content-plan-march copy.md

### 2. Clean settings.local.json

Remove Calvino-specific permissions (paths, domains). Replace with a minimal generic template useful for any project.

### 3. Create install.sh

Location: repository root

Usage:
```bash
./install.sh /path/to/target/project
```

Behavior:
- Copies `.claude/commands/`, `.claude/agents/`, `.claude/skills/` to `<target>/.claude/`
- Copies `.claude/CLAUDE.md` only if target doesn't already have one
- Does NOT copy `settings.local.json` (project-specific)
- Prints summary: count of skills, commands, agents copied
- Overwrites existing files (designed for re-running after updates)

### 4. Update CLAUDE.md

- Document `install.sh` usage
- Correct skill count
- Add workflow instructions (edit here -> install to projects)

### What does NOT change

- Flat skill directory structure (no category subfolders)
- Skill names
- Command and agent content
- Files outside `.claude/` (templates/, scripts/, hooks/, mcp/, prompts/)
