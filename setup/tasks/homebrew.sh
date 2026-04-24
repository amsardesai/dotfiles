#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

if [[ "${OSTYPE:-}" != "darwin"* ]]; then
	exit 0
fi

echo_section "🍺 Checking Homebrew..."

if ! command -v brew >/dev/null 2>&1; then
	echo_warn "Homebrew not found (skipping Brewfile)"
	exit 0
fi

echo_success "Homebrew found"

BREW_UPDATE=$(brew update 2>&1) || true
if echo "$BREW_UPDATE" | grep -q "Already up-to-date"; then
	echo_success "Homebrew up-to-date"
else
	echo_success "Updating Homebrew..."
	echo "$BREW_UPDATE" | while read -r line; do
		[ -n "$line" ] && echo_progress "$line"
	done
	echo_success "Homebrew updated"
fi

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
	echo_success "Running brew bundle..."

	BREW_OUTPUT=$(brew bundle --file="$DOTFILES_DIR/Brewfile" 2>&1) || true
	echo "$BREW_OUTPUT" | while read -r line; do
		[ -n "$line" ] && echo_progress "$line"
	done

	echo_success "Brewfile complete"
fi
