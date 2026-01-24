#!/bin/bash
# =============================================================================
# Claude Code Statusline
# =============================================================================
# Displays a dense, informative statusline with context, git, model, and cost.
#
# Output format:
#   ~/project ⎇ main │ ✓2 ✗1 │ ●●○○○ 42% │ opus │ $0.23
#
# Receives JSON from Claude Code via stdin with fields:
#   - workspace.current_dir
#   - model.display_name
#   - cost.total_cost_usd
#   - context_window.used_percentage
# =============================================================================

# Read JSON from stdin
input=$(cat)

# Parse JSON fields
CWD=$(echo "$input" | jq -r '.workspace.current_dir // empty')
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"' | tr '[:upper:]' '[:lower:]')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CONTEXT_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Abbreviate CWD (replace $HOME with ~)
CWD="${CWD/#$HOME/~}"

# Truncate long paths to last 2 components
PATH_DEPTH=$(echo "$CWD" | tr '/' '\n' | grep -c .)
if [[ $PATH_DEPTH -gt 3 ]]; then
	CWD="…/$(echo "$CWD" | rev | cut -d'/' -f1-2 | rev)"
fi

# Git info (only if in a git repo)
BRANCH=""
GIT_STATUS=""
if git rev-parse --git-dir >/dev/null 2>&1; then
	BRANCH=$(git branch --show-current 2>/dev/null)
	STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
	UNSTAGED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
	[[ $STAGED -gt 0 ]] && GIT_STATUS="✓$STAGED"
	[[ $UNSTAGED -gt 0 ]] && GIT_STATUS="$GIT_STATUS ✗$UNSTAGED"
	GIT_STATUS=$(echo "$GIT_STATUS" | sed 's/^ //')
fi

# Context dots (5 dots, filled based on percentage)
# Remove decimal for calculation
CONTEXT_INT=${CONTEXT_PCT%.*}
FILLED=$((CONTEXT_INT / 20))
[[ $FILLED -gt 5 ]] && FILLED=5
EMPTY=$((5 - FILLED))

# Color based on usage (use $'...' for proper escape interpretation)
if [[ $CONTEXT_INT -ge 80 ]]; then
	DOT_COLOR=$'\033[31m' # Red
elif [[ $CONTEXT_INT -ge 50 ]]; then
	DOT_COLOR=$'\033[33m' # Yellow
else
	DOT_COLOR=$'\033[32m' # Green
fi

# ANSI color codes (use $'...' for proper escape interpretation)
RESET=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
RED=$'\033[31m'

# Build filled and empty dots
FILLED_DOTS=""
EMPTY_DOTS=""
for ((i = 0; i < FILLED; i++)); do FILLED_DOTS+="●"; done
for ((i = 0; i < EMPTY; i++)); do EMPTY_DOTS+="○"; done

DOTS="${DOT_COLOR}${FILLED_DOTS}${EMPTY_DOTS}${RESET}"
CONTEXT_DISPLAY="$DOTS ${CONTEXT_INT}%"

# Build git section with colors
GIT_SECTION=""
if [[ -n "$BRANCH" ]]; then
	GIT_SECTION=" ⎇ $BRANCH"
fi
if [[ -n "$GIT_STATUS" ]]; then
	# Build colored status directly (sed doesn't handle ANSI escapes well)
	COLORED_STATUS=""
	if [[ $STAGED -gt 0 ]]; then
		COLORED_STATUS="${GREEN}✓${STAGED}${RESET}"
	fi
	if [[ $UNSTAGED -gt 0 ]]; then
		[[ -n "$COLORED_STATUS" ]] && COLORED_STATUS="$COLORED_STATUS "
		COLORED_STATUS="${COLORED_STATUS}${RED}✗${UNSTAGED}${RESET}"
	fi
	GIT_SECTION="$GIT_SECTION ${DIM}│${RESET} $COLORED_STATUS"
fi

# Format cost with 2 decimal places
COST_FMT=$(printf '$%.2f' "$COST")

# Build final output
OUTPUT="${CWD}${GIT_SECTION} ${DIM}│${RESET} ${CONTEXT_DISPLAY} ${DIM}│${RESET} ${MODEL} ${DIM}│${RESET} ${COST_FMT}"

# Output single line (ANSI escapes already literal via $'...' syntax)
echo "$OUTPUT"
