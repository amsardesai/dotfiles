#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

WEZTERM_TERMINFO_URL="https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo"
WEZTERM_TERMINFO_FILE="$DOTFILES_DIR/wezterm.terminfo"

if infocmp -A "$HOME/.terminfo" wezterm >/dev/null 2>&1; then
	echo_success "WezTerm terminfo exists"
	exit 0
fi

if [ ! -f "$WEZTERM_TERMINFO_FILE" ]; then
	curl -fsSL "$WEZTERM_TERMINFO_URL" -o "$WEZTERM_TERMINFO_FILE" 2>/dev/null
fi

if [ -f "$WEZTERM_TERMINFO_FILE" ] && [ -s "$WEZTERM_TERMINFO_FILE" ]; then
	mkdir -p "$HOME/.terminfo"
	if tic -o "$HOME/.terminfo" "$WEZTERM_TERMINFO_FILE" 2>/dev/null; then
		echo_success "WezTerm terminfo compiled"
	else
		echo_warn "WezTerm terminfo failed (using fallback)"
	fi
else
	echo_warn "WezTerm terminfo download failed (using fallback)"
fi
