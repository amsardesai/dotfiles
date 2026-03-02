#!/bin/bash
# =============================================================================
# Claude Code Statusline
# =============================================================================
# Displays a dense, informative statusline with context, git, model, and cost.
# Always shows all components - no progressive truncation.
# Branch names are center-truncated to max 20 characters.
#
# Format: ~/project → main │ ✓2 ✗1 │ ●●○○○ 42% │ opus 1m │ $0.23
#
# Receives JSON from Claude Code via stdin.
# =============================================================================

# Read JSON from stdin
input=$(cat)

# Parse JSON fields
CWD=$(echo "$input" | jq -r '.workspace.current_dir // empty')
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"' | awk '{print tolower($1)}')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
if [[ $CONTEXT_SIZE -ge 1000000 ]]; then
	MODEL="${MODEL} 1m"
fi
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CONTEXT_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# ANSI color codes
RESET=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
RED=$'\033[31m'
SEP="${DIM}│${RESET}"

# Context percentage (remove decimal)
CONTEXT_INT=${CONTEXT_PCT%.*}

# Color based on usage
if [[ $CONTEXT_INT -ge 80 ]]; then
	CTX_COLOR=$'\033[31m'
elif [[ $CONTEXT_INT -ge 50 ]]; then
	CTX_COLOR=$'\033[33m'
else
	CTX_COLOR=$'\033[32m'
fi

# Build context dots
FILLED=$((CONTEXT_INT / 20))
[[ $FILLED -gt 5 ]] && FILLED=5
EMPTY=$((5 - FILLED))
FILLED_DOTS=""
EMPTY_DOTS=""
for ((i = 0; i < FILLED; i++)); do FILLED_DOTS+="●"; done
for ((i = 0; i < EMPTY; i++)); do EMPTY_DOTS+="○"; done
DOTS="${CTX_COLOR}${FILLED_DOTS}${EMPTY_DOTS}${RESET}"

# Context display
CTX_WITH_DOTS="$DOTS ${CTX_COLOR}${CONTEXT_INT}%${RESET}"

# Format cost
COST_FMT=$(printf '$%.2f' "$COST")

# Abbreviate CWD
CWD="${CWD/#$HOME/~}"

# Truncate string from middle (like lualine)
truncate_middle() {
	local str="$1"
	local max_len="$2"

	if [[ ${#str} -le $max_len ]]; then
		echo "$str"
		return
	fi

	if [[ $max_len -lt 3 ]]; then
		echo "${str:0:$max_len}"
		return
	fi

	local keep=$((max_len - 1)) # -1 for ellipsis
	local left=$((keep / 2))
	local right=$((keep - left))
	echo "${str:0:$left}…${str: -$right}"
}

# Git info
BRANCH=""
GIT_STATUS_DISPLAY=""
STAGED=0
UNSTAGED=0
if git rev-parse --git-dir >/dev/null 2>&1; then
	BRANCH=$(git branch --show-current 2>/dev/null)
	# Always truncate branch to max 20 chars (like lualine)
	[[ ${#BRANCH} -gt 20 ]] && BRANCH=$(truncate_middle "$BRANCH" 20)
	STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
	UNSTAGED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

	if [[ $STAGED -gt 0 ]] || [[ $UNSTAGED -gt 0 ]]; then
		[[ $STAGED -gt 0 ]] && GIT_STATUS_DISPLAY="${GREEN}✓${STAGED}${RESET}"
		if [[ $UNSTAGED -gt 0 ]]; then
			[[ -n "$GIT_STATUS_DISPLAY" ]] && GIT_STATUS_DISPLAY="$GIT_STATUS_DISPLAY "
			GIT_STATUS_DISPLAY="${GIT_STATUS_DISPLAY}${RED}✗${UNSTAGED}${RESET}"
		fi
	fi
fi

# Build output - always show all components (no progressive truncation)
build_output() {
	local output=""
	[[ -n "$CWD" ]] && output="$CWD → "
	[[ -n "$BRANCH" ]] && output="${output}${BRANCH}"
	[[ -n "$GIT_STATUS_DISPLAY" ]] && output="${output} ${SEP} $GIT_STATUS_DISPLAY"
	output="${output} ${SEP} $CTX_WITH_DOTS"
	output="${output} ${SEP} $MODEL"
	output="${output} ${SEP} $COST_FMT"
	echo "$output"
}

# Build and output
OUTPUT=$(build_output)
echo "$OUTPUT"
