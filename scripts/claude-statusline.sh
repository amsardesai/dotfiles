#!/bin/bash
# =============================================================================
# Claude Code Statusline
# =============================================================================
# Displays a dense, informative statusline with context, git, model, and cost.
# Adapts layout based on terminal width with progressive truncation.
#
# Progressive removal order (widest to narrowest):
#   Full:    ~/project → main │ ✓2 ✗1 │ ●●○○○ 42% │ opus │ $0.23
#   -cost:   ~/project → main │ ✓2 ✗1 │ ●●○○○ 42% │ opus
#   -model:  ~/project → main │ ✓2 ✗1 │ ●●○○○ 42%
#   -git:    ~/project → main │ ●●○○○ 42%
#   -dots:   ~/project → main │ 42%
#   -path:   main │ 42%
#   minimal: ma…in 42%
#
# Receives JSON from Claude Code via stdin.
# =============================================================================

# Read JSON from stdin
input=$(cat)

# Get terminal width for Claude Code statusline
# IMPORTANT: Claude Code's statusline area is often narrower than the terminal.
# The COLUMNS env var reflects terminal width, not statusline width.
# Use CLAUDE_STATUSLINE_WIDTH env var to override, or default to conservative 40.
TERM_WIDTH=${CLAUDE_STATUSLINE_WIDTH:-40}

# Parse JSON fields
CWD=$(echo "$input" | jq -r '.workspace.current_dir // empty')
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"' | awk '{print tolower($1)}')
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

# Context displays
CTX_WITH_DOTS="$DOTS ${CTX_COLOR}${CONTEXT_INT}%${RESET}"
CTX_NO_DOTS="${CTX_COLOR}${CONTEXT_INT}%${RESET}"

# Format cost
COST_FMT=$(printf '$%.2f' "$COST")

# Abbreviate CWD
CWD="${CWD/#$HOME/~}"

# Git info
BRANCH=""
GIT_STATUS_DISPLAY=""
STAGED=0
UNSTAGED=0
if git rev-parse --git-dir >/dev/null 2>&1; then
	BRANCH=$(git branch --show-current 2>/dev/null)
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

# Calculate visible length (strip ANSI codes)
visible_len() {
	echo -n "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' '
}

# Truncate path to fit width
truncate_path() {
	local path="$1"
	local max_len="$2"

	if [[ ${#path} -le $max_len ]]; then
		echo "$path"
		return
	fi

	local short="…/$(echo "$path" | rev | cut -d'/' -f1-2 | rev)"
	if [[ ${#short} -le $max_len ]]; then
		echo "$short"
		return
	fi

	short="…/$(basename "$path")"
	if [[ ${#short} -le $max_len ]]; then
		echo "$short"
		return
	fi

	local base=$(basename "$path")
	local max_base=$((max_len - 2))
	if [[ $max_base -gt 0 ]]; then
		echo "…/${base:0:$max_base}…"
	else
		echo "…"
	fi
}

# Truncate string from middle (like neovim title)
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

	local keep=$((max_len - 1))  # -1 for ellipsis
	local left=$((keep / 2))
	local right=$((keep - left))
	echo "${str:0:$left}…${str: -$right}"
}

# Build output with progressive truncation
build_output() {
	local width=$1

	# Component pieces (will be assembled based on available width)
	local path_arrow=""
	[[ -n "$CWD" ]] && path_arrow="$CWD → "

	local branch_part=""
	[[ -n "$BRANCH" ]] && branch_part="$BRANCH"

	local git_status_part=""
	if [[ -n "$GIT_STATUS_DISPLAY" ]]; then
		git_status_part=" ${SEP} $GIT_STATUS_DISPLAY"
	fi

	local dots_part=" ${SEP} $CTX_WITH_DOTS"
	local pct_part=" ${SEP} $CTX_NO_DOTS"
	local model_part=" ${SEP} $MODEL"
	local cost_part=" ${SEP} $COST_FMT"

	# Try layouts from widest to narrowest

	# Layout 1: Full - path → branch │ git │ dots % │ model │ cost
	local full="${path_arrow}${branch_part}${git_status_part}${dots_part}${model_part}${cost_part}"
	if [[ $(visible_len "$full") -le $width ]]; then
		echo "$full"
		return
	fi

	# Layout 2: Remove cost
	local no_cost="${path_arrow}${branch_part}${git_status_part}${dots_part}${model_part}"
	if [[ $(visible_len "$no_cost") -le $width ]]; then
		echo "$no_cost"
		return
	fi

	# Layout 3: Remove model
	local no_model="${path_arrow}${branch_part}${git_status_part}${dots_part}"
	if [[ $(visible_len "$no_model") -le $width ]]; then
		echo "$no_model"
		return
	fi

	# Layout 4: Remove git status
	local no_git="${path_arrow}${branch_part}${dots_part}"
	if [[ $(visible_len "$no_git") -le $width ]]; then
		echo "$no_git"
		return
	fi

	# Layout 5: Remove dots (keep percentage)
	local no_dots="${path_arrow}${branch_part}${pct_part}"
	if [[ $(visible_len "$no_dots") -le $width ]]; then
		echo "$no_dots"
		return
	fi

	# Layout 6: Remove path (just branch │ %)
	local just_branch="${branch_part}${pct_part}"
	if [[ $(visible_len "$just_branch") -le $width ]]; then
		echo "$just_branch"
		return
	fi

	# Layout 7: Truncate branch from middle, no separator
	# Format: "bra…nch 42%"
	local pct_only="${CTX_NO_DOTS}"
	local pct_len=$(visible_len " $pct_only")
	local branch_space=$((width - pct_len))

	if [[ $branch_space -ge 3 ]] && [[ -n "$BRANCH" ]]; then
		local short_branch=$(truncate_middle "$BRANCH" $branch_space)
		echo "${short_branch} ${pct_only}"
		return
	fi

	# Absolute minimum: just percentage
	echo "$pct_only"
}

# Build and output
OUTPUT=$(build_output "$TERM_WIDTH")
echo "$OUTPUT"
