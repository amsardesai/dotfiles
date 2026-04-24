#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

echo_section "⚙️  Configuring git..."

if ! command -v git >/dev/null 2>&1; then
	echo_warn "Git not found (skipping git config)"
	exit 0
fi

GIT_UPDATED=0
GIT_FAILED=0

if ! [ -f "$HOME/.gitconfig" ]; then
	if touch "$HOME/.gitconfig" 2>/dev/null; then
		GIT_UPDATED=$((GIT_UPDATED + 1))
	else
		GIT_FAILED=1
	fi
fi

if [ $GIT_FAILED -eq 0 ] && ! grep -Fq "path = $DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig" 2>/dev/null; then
	if {
		echo ""
		echo "[include]"
		echo "	path = $DOTFILES_DIR/.gitconfig"
		echo ""
	} >>"$HOME/.gitconfig" 2>/dev/null; then
		GIT_UPDATED=$((GIT_UPDATED + 1))
	else
		GIT_FAILED=1
	fi
fi

if [ $GIT_FAILED -gt 0 ]; then
	echo_warn "Failed to configure git"
elif [ $GIT_UPDATED -gt 0 ]; then
	echo_success "Git configured"
else
	echo_success "Git already configured"
fi
