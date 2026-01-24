#!/bin/bash
# =============================================================================
# Claude Code Statusline
# =============================================================================
# Displays a dense, informative statusline with context, git, model, and cost.
# Adapts layout based on terminal width.
#
# Layouts by width:
#   Wide (80+):   ~/project ⎇ main │ ✓2 ✗1 │ ●●○○○ 42% │ opus │ $0.23
#   Medium (60+): ~/project ⎇ main │ ✓2 ✗1 │ 42% │ opus │ $0.23
#   Narrow (45+): ~/project ⎇ main │ 42% │ opus │ $0.23
#   Minimal:      ●●○○○ 42% │ opus │ $0.23
#
# Receives JSON from Claude Code via stdin.
# =============================================================================

# Read JSON from stdin
input=$(cat)

# Get terminal width - try multiple methods since subprocess may not have TTY
# Priority: COLUMNS env var > tput via /dev/tty > stty > fallback
if [[ -n "$COLUMNS" ]]; then
	TERM_WIDTH=$COLUMNS
elif [[ -r /dev/tty ]]; then
	TERM_WIDTH=$(tput cols </dev/tty 2>/dev/null) || TERM_WIDTH=0
fi
if [[ -z "$TERM_WIDTH" ]] || [[ "$TERM_WIDTH" -eq 0 ]]; then
	TERM_WIDTH=$(stty size 2>/dev/null | cut -d' ' -f2 || echo 0)
fi
if [[ -z "$TERM_WIDTH" ]] || [[ "$TERM_WIDTH" -eq 0 ]]; then
	TERM_WIDTH=60  # Conservative fallback for Claude Code context
fi

# Parse JSON fields
CWD=$(echo "$input" | jq -r '.workspace.current_dir // empty')
# Extract just the model name (first word, lowercase) - strips version numbers like "Opus 4.5" -> "opus"
MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"' | awk '{print tolower($1)}')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
CONTEXT_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# ANSI color codes (use $'...' for proper escape interpretation)
RESET=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
RED=$'\033[31m'
SEP="${DIM}│${RESET}"

# Context percentage (remove decimal)
CONTEXT_INT=${CONTEXT_PCT%.*}

# Color based on usage
if [[ $CONTEXT_INT -ge 80 ]]; then
	CTX_COLOR=$'\033[31m' # Red
elif [[ $CONTEXT_INT -ge 50 ]]; then
	CTX_COLOR=$'\033[33m' # Yellow
else
	CTX_COLOR=$'\033[32m' # Green
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

# Abbreviate CWD (replace $HOME with ~)
CWD="${CWD/#$HOME/~}"

# Git info (only if in a git repo)
BRANCH=""
GIT_STATUS_DISPLAY=""
if git rev-parse --git-dir >/dev/null 2>&1; then
	BRANCH=$(git branch --show-current 2>/dev/null)
	STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
	UNSTAGED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')

	if [[ $STAGED -gt 0 ]] || [[ $UNSTAGED -gt 0 ]]; then
		GIT_STATUS_DISPLAY=""
		[[ $STAGED -gt 0 ]] && GIT_STATUS_DISPLAY="${GREEN}✓${STAGED}${RESET}"
		if [[ $UNSTAGED -gt 0 ]]; then
			[[ -n "$GIT_STATUS_DISPLAY" ]] && GIT_STATUS_DISPLAY="$GIT_STATUS_DISPLAY "
			GIT_STATUS_DISPLAY="${GIT_STATUS_DISPLAY}${RED}✗${UNSTAGED}${RESET}"
		fi
	fi
fi

# Helper: truncate path to fit width
truncate_path() {
	local path="$1"
	local max_len="$2"

	if [[ ${#path} -le $max_len ]]; then
		echo "$path"
		return
	fi

	# Try last 2 components with ellipsis
	local short="…/$(echo "$path" | rev | cut -d'/' -f1-2 | rev)"
	if [[ ${#short} -le $max_len ]]; then
		echo "$short"
		return
	fi

	# Try just the last component
	short="…/$(basename "$path")"
	if [[ ${#short} -le $max_len ]]; then
		echo "$short"
		return
	fi

	# Truncate the basename itself
	local base=$(basename "$path")
	local max_base=$((max_len - 2))
	if [[ $max_base -gt 0 ]]; then
		echo "…/${base:0:$max_base}…"
	else
		echo "…"
	fi
}

# Calculate visible length (strip ANSI codes)
visible_len() {
	echo -n "$1" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' '
}

# Build components for different layouts
build_output() {
	local width=$1
	local output=""

	# Core components (always shown)
	local core="${CTX_WITH_DOTS} ${SEP} ${MODEL} ${SEP} ${COST_FMT}"
	local core_no_dots="${CTX_NO_DOTS} ${SEP} ${MODEL} ${SEP} ${COST_FMT}"
	local core_len=$(visible_len "$core")
	local core_no_dots_len=$(visible_len "$core_no_dots")

	# If we can't even fit core, show minimal
	if [[ $width -lt $core_no_dots_len ]]; then
		echo "${CTX_NO_DOTS} ${SEP} ${MODEL}"
		return
	fi

	# Calculate space for path and git
	local remaining=$((width - core_len - 3)) # 3 for " │ " separator

	# Build git section
	local git_section=""
	local git_section_plain=""
	if [[ -n "$BRANCH" ]]; then
		git_section=" ⎇ $BRANCH"
		git_section_plain=" ⎇ $BRANCH"
		if [[ -n "$GIT_STATUS_DISPLAY" ]]; then
			git_section="$git_section ${SEP} $GIT_STATUS_DISPLAY"
			git_section_plain="$git_section_plain │ $(echo "$GIT_STATUS_DISPLAY" | sed 's/\x1b\[[0-9;]*m//g')"
		fi
	fi
	local git_len=${#git_section_plain}

	# Calculate max path length
	local path_space=$((remaining - git_len - 1))

	# Wide layout: full path + git + dots
	if [[ $path_space -ge 15 ]] && [[ $width -ge 80 ]]; then
		local display_path=$(truncate_path "$CWD" $path_space)
		echo "${display_path}${git_section} ${SEP} ${core}"
		return
	fi

	# Medium layout: shorter path + git + no dots
	remaining=$((width - core_no_dots_len - 3))
	path_space=$((remaining - git_len - 1))

	if [[ $path_space -ge 10 ]] && [[ $width -ge 60 ]]; then
		local display_path=$(truncate_path "$CWD" $path_space)
		echo "${display_path}${git_section} ${SEP} ${core_no_dots}"
		return
	fi

	# Narrow layout: path + branch only (no git status) + no dots
	if [[ -n "$BRANCH" ]]; then
		git_section=" ⎇ $BRANCH"
		git_len=$((${#BRANCH} + 3))
	else
		git_section=""
		git_len=0
	fi
	path_space=$((remaining - git_len - 1))

	if [[ $path_space -ge 8 ]] && [[ $width -ge 45 ]]; then
		local display_path=$(truncate_path "$CWD" $path_space)
		echo "${display_path}${git_section} ${SEP} ${core_no_dots}"
		return
	fi

	# Minimal layout: just context + model + cost (with dots if space)
	if [[ $width -ge $core_len ]]; then
		echo "$core"
	else
		echo "$core_no_dots"
	fi
}

# Build and output
OUTPUT=$(build_output "$TERM_WIDTH")
echo "$OUTPUT"
