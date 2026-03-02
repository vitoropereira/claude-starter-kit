#!/usr/bin/env bash
set -euo pipefail

# Ralph Loop — AFK autonomous PRD executor
# Usage: ./scripts/ralph.sh <PRD_NUMBER> [max_iterations]
#
# Example: ./scripts/ralph.sh 01 20
#
# Reads docs/prds/prd-XX.json, implements tasks one by one via Claude Code,
# verifies with quality gates, commits each task, and tracks progress.
#
# Safeguards:
#   - Max iterations (default 30)
#   - Circuit breaker (3 consecutive fails = stop)
#   - 5s delay between iterations
#   - Restricted tool permissions
#   - $5 budget cap per iteration
#   - Branch isolation (run ralph-setup.sh first)
#
# IMPORTANT: Run from a standalone terminal, NOT inside Claude Code.
#            claude -p cannot nest inside another Claude Code session.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROGRESS_FILE="$PROJECT_ROOT/progress.txt"

# ─── Arguments ────────────────────────────────────────────────────────

if [ $# -lt 1 ]; then
    echo "Usage: ./scripts/ralph.sh <PRD_NUMBER> [max_iterations]"
    echo ""
    echo "Available PRDs:"
    ls "$PROJECT_ROOT/docs/prds/prd-"*.json 2>/dev/null | while read f; do
        num=$(basename "$f" | sed 's/prd-\(.*\)\.json/\1/')
        desc=$(jq -r '.description' "$f" 2>/dev/null || echo "???")
        echo "  $num — $desc"
    done
    exit 1
fi

PRD_NUMBER="$1"
PRD_FILE="$PROJECT_ROOT/docs/prds/prd-${PRD_NUMBER}.json"

# Configuration
MAX_ITERATIONS=${2:-30}
MAX_CONSECUTIVE_FAILS=3
SLEEP_BETWEEN=5

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# State
ITERATION=0
FAIL_COUNT=0
COMPLETE_SIGNAL="RALPH_COMPLETE"

# ─── Prompt ──────────────────────────────────────────────────────────

PROMPT_FILE="$SCRIPT_DIR/RALPH_PROMPT.md"

if [ ! -f "$PROMPT_FILE" ]; then
    echo -e "${RED}Error: RALPH_PROMPT.md not found at $PROMPT_FILE${NC}"
    exit 1
fi

RALPH_PROMPT=$(cat "$PROMPT_FILE")
# Replace the PRD path placeholder
RALPH_PROMPT="${RALPH_PROMPT//PRD_JSON_PATH/docs/prds/prd-${PRD_NUMBER}.json}"

# ─── Functions ───────────────────────────────────────────────────────

count_passed() {
    jq '[.tasks[] | select(.passes == true)] | length' "$PRD_FILE"
}

count_total() {
    jq '.tasks | length' "$PRD_FILE"
}

get_next_task_id() {
    jq -r '[.tasks[] | select(.passes == false)] | sort_by(.priority) | .[0].id // "NONE"' "$PRD_FILE"
}

log() {
    local timestamp
    timestamp=$(date "+%H:%M:%S")
    echo -e "${CYAN}[$timestamp]${NC} $1"
}

# ─── Pre-flight checks ──────────────────────────────────────────────

if [ ! -f "$PRD_FILE" ]; then
    echo -e "${RED}Error: $PRD_FILE not found.${NC}"
    echo "Run ./scripts/ralph-setup.sh $PRD_NUMBER first."
    exit 1
fi

if ! jq empty "$PRD_FILE" 2>/dev/null; then
    echo -e "${RED}Error: $PRD_FILE is not valid JSON.${NC}"
    exit 1
fi

PRD_NUMBER_JSON=$(jq -r '.prdNumber' "$PRD_FILE")
DESCRIPTION=$(jq -r '.description' "$PRD_FILE")
TOTAL=$(count_total)
PASSED_START=$(count_passed)

echo ""
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}       RALPH LOOP — AFK MODE           ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""
echo -e "PRD:            ${GREEN}$PRD_NUMBER_JSON${NC} — $DESCRIPTION"
echo -e "Stories:        ${GREEN}$PASSED_START${NC}/$TOTAL passed"
echo -e "Max iterations: ${YELLOW}$MAX_ITERATIONS${NC}"
echo -e "Circuit breaker: ${YELLOW}$MAX_CONSECUTIVE_FAILS consecutive fails${NC}"
echo ""

if [ "$PASSED_START" -eq "$TOTAL" ]; then
    echo -e "${GREEN}All tasks already passed! Nothing to do.${NC}"
    exit 0
fi

# ─── Main Loop ───────────────────────────────────────────────────────

while [ "$ITERATION" -lt "$MAX_ITERATIONS" ]; do
    ITERATION=$((ITERATION + 1))
    NEXT_TASK=$(get_next_task_id)

    if [ "$NEXT_TASK" = "NONE" ]; then
        FINAL_PASSED=$(count_passed)
        log "${GREEN}All tasks complete!${NC}"
        echo ""
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}       ALL TASKS COMPLETE              ${NC}"
        echo -e "${GREEN}=======================================${NC}"
        echo -e "Tasks: $FINAL_PASSED/$TOTAL passed in $ITERATION iterations"
        exit 0
    fi

    PASSED_NOW=$(count_passed)
    log "${BLUE}--- Iteration $ITERATION/$MAX_ITERATIONS --- Next: $NEXT_TASK ($PASSED_NOW/$TOTAL passed) ---${NC}"

    # Snapshot passed count before this iteration
    PASSED_BEFORE_ITER=$(count_passed)

    # Build the prompt with iteration number
    ITER_PROMPT="${RALPH_PROMPT//ITER_NUM/$ITERATION}"

    # Execute Claude Code in print mode with restricted tools
    # CUSTOMIZE: Adjust --allowedTools Bash commands to match your project's quality gate commands
    OUTPUT=$(claude -p \
        --allowedTools "Read,Write,Edit,Glob,Grep,Bash(npm run clean),Bash(npm run type-check),Bash(git add:*),Bash(git commit:*),Bash(git status),Bash(git diff)" \
        --max-budget-usd 5 \
        "$ITER_PROMPT" 2>&1) || true

    # Check for completion signal
    if echo "$OUTPUT" | grep -q "$COMPLETE_SIGNAL"; then
        FINAL_PASSED=$(count_passed)
        log "${GREEN}RALPH_COMPLETE received!${NC}"
        echo ""
        echo -e "${GREEN}=======================================${NC}"
        echo -e "${GREEN}       ALL TASKS COMPLETE              ${NC}"
        echo -e "${GREEN}=======================================${NC}"
        echo -e "Tasks: $FINAL_PASSED/$TOTAL passed in $ITERATION iterations"
        exit 0
    fi

    # Check if progress was made (more tasks passed than before)
    PASSED_AFTER_ITER=$(count_passed)
    if [ "$PASSED_AFTER_ITER" -gt "$PASSED_BEFORE_ITER" ]; then
        FAIL_COUNT=0
        log "${GREEN}Progress! $PASSED_AFTER_ITER/$TOTAL tasks passed.${NC}"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        log "${YELLOW}No progress this iteration. Fail count: $FAIL_COUNT/$MAX_CONSECUTIVE_FAILS${NC}"
    fi

    # Circuit breaker
    if [ "$FAIL_COUNT" -ge "$MAX_CONSECUTIVE_FAILS" ]; then
        FINAL_PASSED=$(count_passed)
        log "${RED}Circuit breaker tripped!${NC}"
        echo ""
        echo -e "${RED}=======================================${NC}"
        echo -e "${RED}     CIRCUIT BREAKER — STOPPED         ${NC}"
        echo -e "${RED}=======================================${NC}"
        echo -e "Tasks: $FINAL_PASSED/$TOTAL passed in $ITERATION iterations"
        echo -e "Check progress.txt and prd-${PRD_NUMBER}.json for details."
        exit 1
    fi

    # Rate limit delay
    if [ "$ITERATION" -lt "$MAX_ITERATIONS" ]; then
        log "Sleeping ${SLEEP_BETWEEN}s..."
        sleep "$SLEEP_BETWEEN"
    fi
done

# Max iterations reached
FINAL_PASSED=$(count_passed)
log "${YELLOW}Max iterations ($MAX_ITERATIONS) reached.${NC}"
echo ""
echo -e "${YELLOW}=======================================${NC}"
echo -e "${YELLOW}     MAX ITERATIONS — STOPPED          ${NC}"
echo -e "${YELLOW}=======================================${NC}"
echo -e "Tasks: $FINAL_PASSED/$TOTAL passed in $ITERATION iterations"
echo -e "Run again: ./scripts/ralph.sh $PRD_NUMBER"
exit 0
