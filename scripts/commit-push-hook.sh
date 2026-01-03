#!/bin/bash
# Pre-gather git info when /commit-push is invoked
# Runs on every prompt but exits early if not /commit-push

# Read input from stdin
input=$(cat)

# Only run for /commit-push skill (exit early otherwise)
if ! echo "$input" | grep -q "commit-push"; then
    exit 0
fi

# Stage all changes and gather info (output to stderr for Claude to see)
git add . 2>&1
echo "=== Staged Changes ===" >&2
git diff --cached --stat >&2
echo "" >&2
echo "=== Full Diff ===" >&2
git diff --cached >&2
echo "" >&2
echo "=== Recent Commits (for style) ===" >&2
git log --oneline -5 >&2

exit 0
