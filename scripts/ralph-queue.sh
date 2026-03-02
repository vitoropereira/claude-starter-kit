#!/usr/bin/env bash
set -euo pipefail

# Ralph Queue — Runs multiple PRDs sequentially
# Usage: ./scripts/ralph-queue.sh [prd_numbers...] [-- max_iterations_per_prd]
#
# Examples:
#   ./scripts/ralph-queue.sh 01 02 03          # Run PRDs 01, 02, 03 with default 15 iterations
#   ./scripts/ralph-queue.sh 01 02 -- 20       # Run PRDs 01, 02 with 20 iterations each
#   ./scripts/ralph-queue.sh                    # Auto-detect all prd-XX.json files
#
# For each PRD:
#   1. Runs ralph-setup.sh (creates branch, validates build)
#   2. Runs ralph.sh (AFK loop)
#   3. On completion, merges branch to main
#   4. Moves to next PRD

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Parse arguments: PRD numbers before --, max_iterations after --
PRDS=()
MAX_ITERS=15

parsing_prds=true
for arg in "$@"; do
    if [ "$arg" = "--" ]; then
        parsing_prds=false
        continue
    fi
    if $parsing_prds; then
        PRDS+=("$arg")
    else
        MAX_ITERS="$arg"
    fi
done

# Auto-detect PRDs if none specified
if [ ${#PRDS[@]} -eq 0 ]; then
    while IFS= read -r f; do
        num=$(basename "$f" | sed 's/prd-\(.*\)\.json/\1/')
        PRDS+=("$num")
    done < <(ls "$PROJECT_ROOT/docs/prds/prd-"*.json 2>/dev/null | sort)

    if [ ${#PRDS[@]} -eq 0 ]; then
        echo -e "${RED}No prd-XX.json files found in docs/prds/${NC}"
        echo "Usage: ./scripts/ralph-queue.sh [prd_numbers...] [-- max_iterations]"
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}       RALPH QUEUE — OVERNIGHT MODE         ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "PRDs queued: ${GREEN}${PRDS[*]}${NC}"
echo -e "Max iterations per PRD: ${YELLOW}$MAX_ITERS${NC}"
echo ""

COMPLETED=0
FAILED=0

for PRD_NUM in "${PRDS[@]}"; do
    PRD_FILE="$PROJECT_ROOT/docs/prds/prd-${PRD_NUM}.json"

    if [ ! -f "$PRD_FILE" ]; then
        echo -e "${RED}Skipping PRD $PRD_NUM: prd-${PRD_NUM}.json not found${NC}"
        FAILED=$((FAILED + 1))
        continue
    fi

    DESCRIPTION=$(jq -r '.description' "$PRD_FILE")
    BRANCH_NAME=$(jq -r '.branchName' "$PRD_FILE")

    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}  Starting PRD $PRD_NUM: $DESCRIPTION${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""

    # Step 1: Clean progress.txt for this PRD
    rm -f "$PROJECT_ROOT/progress.txt"

    # Step 2: Run setup (creates branch, validates build)
    echo ""
    if ! "$SCRIPT_DIR/ralph-setup.sh" "$PRD_NUM"; then
        echo -e "${RED}Setup failed for PRD $PRD_NUM. Skipping.${NC}"
        FAILED=$((FAILED + 1))
        # Return to main for next PRD
        git checkout main 2>/dev/null || true
        continue
    fi

    # Step 3: Run ralph loop
    echo ""
    if "$SCRIPT_DIR/ralph.sh" "$PRD_NUM" "$MAX_ITERS"; then
        echo -e "${GREEN}PRD $PRD_NUM completed successfully!${NC}"

        # Step 4: Merge to main
        echo ""
        echo -e "${BLUE}Merging $BRANCH_NAME -> main...${NC}"
        git checkout main
        git merge "$BRANCH_NAME" --no-edit
        echo -e "${GREEN}Merged $BRANCH_NAME -> main${NC}"

        COMPLETED=$((COMPLETED + 1))
    else
        echo -e "${YELLOW}PRD $PRD_NUM stopped (circuit breaker or max iterations).${NC}"
        echo -e "${YELLOW}Partial progress kept on branch: $BRANCH_NAME${NC}"

        # Still merge partial progress to main
        PASSED=$(jq '[.tasks[] | select(.passes == true)] | length' "$PRD_FILE")
        TOTAL=$(jq '.tasks | length' "$PRD_FILE")

        if [ "$PASSED" -gt 0 ]; then
            echo -e "${BLUE}Merging partial progress ($PASSED/$TOTAL tasks) to main...${NC}"
            git checkout main
            git merge "$BRANCH_NAME" --no-edit
            COMPLETED=$((COMPLETED + 1))
        else
            echo -e "${RED}No tasks passed. Leaving branch as-is.${NC}"
            git checkout main 2>/dev/null || true
            FAILED=$((FAILED + 1))
        fi
    fi

    echo ""
    echo -e "${GREEN}--- PRD $PRD_NUM done ---${NC}"
    sleep 3
done

# Final summary
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}       RALPH QUEUE — COMPLETE               ${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "Completed: ${GREEN}$COMPLETED${NC} PRDs"
echo -e "Failed:    ${RED}$FAILED${NC} PRDs"
echo ""
echo -e "Review changes: ${CYAN}git log --oneline -20${NC}"
echo -e "Push when ready: ${CYAN}git push origin main${NC}"
