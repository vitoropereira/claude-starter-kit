You are implementing a PRD autonomously. This is iteration ITER_NUM of a ralph loop.

## Instructions

1. Read PRD_JSON_PATH from the project
2. Read progress.txt for context from previous iterations
3. Find the first task where "passes" is false (sorted by priority)
4. If no pending tasks exist, output RALPH_COMPLETE and stop
5. Check dependencies: all tasks in the task's "dependsOn" must have status "passed"
6. Read the task's taskFile for detailed implementation instructions
7. Read all files listed in the task's filesToModify to understand current state
8. Implement the changes described in the task file
9. Run quality gates (from the qualityGates array in the prd JSON):
   - Execute each command in order
   - All must pass before marking the task as done
10. If quality gates pass:
    - Update prd JSON: set the task's "passes" to true, "status" to "passed", increment "attempts", add a brief note
    - Run: git add -A && git commit -m "feat(prd-XX): TASK_ID - brief description"
    - Append a summary to progress.txt with the format:
      --- Iteration ITER_NUM ---
      [TASK_ID] PASSED - What was done
      Files changed: list of files
11. If quality gates fail after 3 fix attempts:
    - Update the task's notes with the error, set status to "blocked"
    - Append the failure to progress.txt
    - Do NOT mark the task as passes:true

## Rules
- ONE task per iteration. Do not attempt multiple tasks.
- Always read files before modifying them.
- Follow existing codebase patterns — read similar files first.
- Do NOT modify files outside the task's filesToModify scope.
- Do NOT run git push.

## Project-Specific Rules
<!-- CUSTOMIZE: Replace this section with your project's rules. Examples below: -->
- Follow all patterns and conventions documented in CLAUDE.md.
- Use the import style consistent with the existing codebase.
- Follow the auth pattern used in the existing codebase.
- Follow the state management approach used in the existing codebase.
- Quality gates are defined in the prd JSON's qualityGates array — run those commands (NOT a hardcoded list).
- Do NOT add unnecessary comments, docstrings, or TODOs.
- Do NOT over-engineer — implement exactly what is asked.

## Completion
When ALL tasks in the prd JSON have "passes": true, output exactly this text on its own line:
RALPH_COMPLETE
