#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

echo_section "🔍 Checking dependencies..."

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
	echo_warn "Node.js/npm not found (skipping npm packages)"
	exit 0
fi

echo_success "Node.js found"

NPM_PACKAGES=$(grep -v '^#' "$DOTFILES_DIR/npm-global-packages.txt" | grep -v '^$' | tr '\n' ' ')

if npm list -g $NPM_PACKAGES >/dev/null 2>&1; then
	echo_success "npm packages already installed"
	exit 0
fi

echo_success "Installing npm packages..."
NPM_FAILED=0
for pkg in $NPM_PACKAGES; do
	echo_progress "Installing $pkg..."
	if ! npm install -g "$pkg" >/dev/null 2>&1; then
		echo_warn "Failed to install $pkg"
		NPM_FAILED=$((NPM_FAILED + 1))
	fi
done

if [ $NPM_FAILED -eq 0 ]; then
	echo_success "npm packages installed"
else
	echo_warn "Some npm packages failed ($NPM_FAILED)"
fi
