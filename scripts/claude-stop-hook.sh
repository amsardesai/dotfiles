#!/bin/bash
# Claude Code Stop Hook - sends notifications for completed long tasks
# (Quality gates removed to avoid conflicts with ralph-wiggum plugin)

# Read input JSON from stdin
input=$(cat)

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

# Always approve - no quality gates
echo '{"decision": "approve"}'
