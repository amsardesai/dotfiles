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
# Notification: Send macOS notification for long tasks when in background
# -----------------------------------------------------------------------------
NOTIFY_THRESHOLD_SECONDS=30

send_notification_if_needed() {
  local transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

  # Skip if no transcript
  [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && return

  # Calculate elapsed time from first/last message timestamps
  local first_ts last_ts
  first_ts=$(jq -r '.[0].timestamp // empty' "$transcript_path" 2>/dev/null)
  last_ts=$(jq -r '.[-1].timestamp // empty' "$transcript_path" 2>/dev/null)

  [ -z "$first_ts" ] || [ -z "$last_ts" ] && return

  # Convert ISO 8601 to epoch seconds and calculate difference
  local start_epoch end_epoch elapsed
  start_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${first_ts%%.*}" "+%s" 2>/dev/null) || return
  end_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${last_ts%%.*}" "+%s" 2>/dev/null) || return
  elapsed=$((end_epoch - start_epoch))

  # Skip if task was quick
  [ "$elapsed" -lt "$NOTIFY_THRESHOLD_SECONDS" ] && return

  # Check if terminal is in foreground - skip notification if so
  local frontmost
  frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
  case "$frontmost" in
    WezTerm|wezterm-gui|kitty|Terminal|iTerm2) return ;;
  esac

  # Format elapsed time nicely
  local time_str
  if [ "$elapsed" -ge 60 ]; then
    time_str="$((elapsed / 60))m $((elapsed % 60))s"
  else
    time_str="${elapsed}s"
  fi

  # Send notification - use terminal-notifier with -ignoreDnD if available
  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
      -title "Claude Code" \
      -message "Task completed (${time_str})" \
      -sound "Glass" \
      -ignoreDnD \
      -group "claude-code" &>/dev/null
  else
    # Fallback to osascript (won't bypass Focus Mode)
    osascript -e "display notification \"Task completed (${time_str})\" with title \"Claude Code\" sound name \"Glass\"" &>/dev/null
  fi
}

# Run async to not block the hook response
send_notification_if_needed &

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
