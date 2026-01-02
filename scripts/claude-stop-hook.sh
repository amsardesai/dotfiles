#!/bin/bash
# Claude Code Stop Hook - blocks if work appears incomplete
# Checks: 1) incomplete todos, 2) uncommitted git changes

# Read input JSON from stdin
input=$(cat)

# Extract fields from hook input
session_id=$(echo "$input" | jq -r '.session_id // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')

# Collect all blocking reasons
reasons=()

# -----------------------------------------------------------------------------
# Check 1: Incomplete todos
# -----------------------------------------------------------------------------
if [ -n "$session_id" ]; then
  todo_file="$HOME/.claude/todos/${session_id}-agent-${session_id}.json"
  if [ -f "$todo_file" ]; then
    incomplete=$(jq '[.[] | select(.status == "pending" or .status == "in_progress")] | length' "$todo_file" 2>/dev/null || echo "0")
    if [ "$incomplete" -gt 0 ]; then
      reasons+=("$incomplete incomplete todo(s)")
    fi
  fi
fi

# -----------------------------------------------------------------------------
# Check 2: Uncommitted git changes in working directory
# -----------------------------------------------------------------------------
if [ -n "$cwd" ] && [ -d "$cwd/.git" ]; then
  # Check for staged but uncommitted changes
  staged=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  if [ "$staged" -gt 0 ]; then
    reasons+=("$staged staged but uncommitted file(s)")
  fi
fi

# -----------------------------------------------------------------------------
# Build response
# -----------------------------------------------------------------------------
if [ ${#reasons[@]} -gt 0 ]; then
  # Join reasons with semicolons
  reason_text=$(IFS='; '; echo "${reasons[*]}")
  echo "{\"decision\": \"block\", \"reason\": \"$reason_text\"}"
else
  echo "{\"decision\": \"approve\", \"reason\": \"all checks passed\"}"
fi
