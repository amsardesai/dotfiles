#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

echo_section "🐚 Configuring shell..."

SHELL_UPDATED=0
SHELL_FAILED=0

if ! [ -f "$HOME/.bash_profile" ] || ! grep -Fq "source $DOTFILES_DIR/.profile" "$HOME/.bash_profile" 2>/dev/null; then
	if {
		echo ""
		echo "# Source Ankit's profile"
		echo "source $DOTFILES_DIR/.profile"
		echo ""
	} >>"$HOME/.bash_profile" 2>/dev/null; then
		SHELL_UPDATED=$((SHELL_UPDATED + 1))
	else
		SHELL_FAILED=$((SHELL_FAILED + 1))
	fi
fi

if ! [ -f "$HOME/.zshrc" ] || ! grep -Fq "source $DOTFILES_DIR/.zshrc" "$HOME/.zshrc" 2>/dev/null; then
	if {
		echo ""
		echo "# Source Ankit's zshrc"
		echo "source $DOTFILES_DIR/.zshrc"
		echo ""
	} >>"$HOME/.zshrc" 2>/dev/null; then
		SHELL_UPDATED=$((SHELL_UPDATED + 1))
	else
		SHELL_FAILED=$((SHELL_FAILED + 1))
	fi
fi

if [ $SHELL_FAILED -gt 0 ]; then
	echo_warn "Failed to update some shell profiles"
elif [ $SHELL_UPDATED -gt 0 ]; then
	echo_success "Updated shell profiles"
else
	echo_success "Shell profiles configured"
fi
