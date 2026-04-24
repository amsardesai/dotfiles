#!/bin/bash

GREEN=2
YELLOW=3
RED=1
CYAN=6
GRAY=8

set_color() {
	if command -v tput >/dev/null 2>&1 && [ -n "${TERM:-}" ]; then
		tput setaf "$1" 2>/dev/null || true
	fi
}

reset_color() {
	if command -v tput >/dev/null 2>&1 && [ -n "${TERM:-}" ]; then
		tput sgr0 2>/dev/null || true
	fi
}

echo_section() {
	printf "\n"
	set_color "$CYAN"
	printf "%s" "$1"
	reset_color
	printf "\n"
}

echo_success() {
	printf "   "
	set_color "$GREEN"
	printf "✓ %s" "$1"
	reset_color
	printf "\n"
}

echo_warn() {
	printf "   "
	set_color "$YELLOW"
	printf "⚠ %s" "$1"
	reset_color
	printf "\n"
}

echo_error() {
	printf "   "
	set_color "$RED"
	printf "✗ %s" "$1"
	reset_color
	printf "\n"
}

echo_progress() {
	set_color "$GRAY"
	printf "     %s" "$1"
	reset_color
	printf "\n"
}
