#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

if ! command -v bat >/dev/null 2>&1; then
	exit 0
fi

BAT_THEMES_DIR="$(bat --config-dir)/themes"
BAT_THEME_FILE="$BAT_THEMES_DIR/tokyonight_night.tmTheme"

if [ -f "$BAT_THEME_FILE" ]; then
	echo_success "Bat Tokyo Night theme exists"
	exit 0
fi

mkdir -p "$BAT_THEMES_DIR"
if curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme" -o "$BAT_THEME_FILE" 2>/dev/null; then
	bat cache --build >/dev/null 2>&1
	echo_success "Bat Tokyo Night theme installed"
else
	echo_warn "Bat theme download failed"
fi
