#!/usr/bin/env bash
set -euo pipefail

# Ralph Setup — Prepares branch and validates prd-XX.json before AFK loop
# Usage: ./scripts/ralph-setup.sh <PRD_NUMBER>
# Example: ./scripts/ralph-setup.sh 01

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROGRESS_FILE="$PROJECT_ROOT/progress.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Ralph Setup ===${NC}"
echo ""

# 1. Validate argument
if [ $# -lt 1 ]; then
    echo "Usage: ./scripts/ralph-setup.sh <PRD_NUMBER>"
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

# 2. Validate prd-XX.json exists
if [ ! -f "$PRD_FILE" ]; then
    echo -e "${RED}Error: $PRD_FILE not found.${NC}"
    echo "Run /ralph $PRD_NUMBER to generate it from a PRD."
    exit 1
fi

# 3. Validate JSON is parseable
if ! jq empty "$PRD_FILE" 2>/dev/null; then
    echo -e "${RED}Error: $PRD_FILE is not valid JSON.${NC}"
    exit 1
fi

# 4. Extract metadata
BRANCH_NAME=$(jq -r '.branchName' "$PRD_FILE")
DESCRIPTION=$(jq -r '.description' "$PRD_FILE")
TOTAL_TASKS=$(jq '.tasks | length' "$PRD_FILE")
PENDING_TASKS=$(jq '[.tasks[] | select(.passes == false)] | length' "$PRD_FILE")
# Read quality gates from prd JSON
QUALITY_GATES=$(jq -r '.qualityGates[]' "$PRD_FILE" 2>/dev/null)

if [ "$BRANCH_NAME" = "null" ] || [ -z "$BRANCH_NAME" ]; then
    echo -e "${RED}Error: prd-${PRD_NUMBER}.json missing branchName field.${NC}"
    exit 1
fi

# 5. Check if branch already exists
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "$BRANCH_NAME" ]; then
    echo -e "${YELLOW}Already on branch: $BRANCH_NAME${NC}"
elif git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo -e "${YELLOW}Branch exists, switching to: $BRANCH_NAME${NC}"
    git checkout "$BRANCH_NAME"
else
    # Use develop as base if it exists, otherwise fall back to main
    BASE_BRANCH="main"
    if git show-ref --verify --quiet "refs/heads/develop"; then
        BASE_BRANCH="develop"
    fi
    echo -e "${GREEN}Creating branch: $BRANCH_NAME (from $BASE_BRANCH)${NC}"
    git checkout "$BASE_BRANCH"
    git pull origin "$BASE_BRANCH" --ff-only 2>/dev/null || true
    git checkout -b "$BRANCH_NAME"
fi

# 6. Create progress.txt if not exists
if [ ! -f "$PROGRESS_FILE" ]; then
    echo "# Ralph Progress Log — PRD $PRD_NUMBER: $DESCRIPTION" > "$PROGRESS_FILE"
    echo "" >> "$PROGRESS_FILE"
    echo -e "${GREEN}Created: progress.txt${NC}"
fi

# 7. Verify quality gates
echo ""
echo -e "${BLUE}Verifying quality gates...${NC}"

if [ -n "$QUALITY_GATES" ]; then
    while IFS= read -r gate; do
        echo -n "  $gate... "
        if eval "$gate" --prefix "$PROJECT_ROOT" > /dev/null 2>&1 || eval "cd $PROJECT_ROOT && $gate" > /dev/null 2>&1; then
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${RED}FAILED${NC}"
            echo -e "${RED}Fix errors before running Ralph.${NC}"
            exit 1
        fi
    done <<< "$QUALITY_GATES"
else
    echo -e "${YELLOW}No quality gates defined in prd-${PRD_NUMBER}.json${NC}"
fi

# 8. Print summary
echo ""
echo -e "${BLUE}=== Ready ===${NC}"
echo -e "PRD:      ${GREEN}$PRD_NUMBER${NC} — $DESCRIPTION"
echo -e "Branch:   ${GREEN}$BRANCH_NAME${NC}"
echo -e "Tasks:    ${GREEN}$PENDING_TASKS${NC} pending / $TOTAL_TASKS total"
echo ""
echo -e "Run: ${YELLOW}./scripts/ralph.sh $PRD_NUMBER${NC}"
