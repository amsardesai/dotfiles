#!/bin/bash
# =============================================================================
# DOTFILES SETUP BOOTSTRAPPER
# =============================================================================
#
# This script only bootstraps a pinned Dotbot release and delegates setup to
# install.conf.yaml. Put setup behavior in Dotbot directives or setup/tasks/.
#
# =============================================================================

SCRIPTPATH="$(cd "$(dirname "$0")" && pwd -P)"

# Dotbot bootstrap constants
# To update: download the new release, run `shasum -a 256 <archive>`, update both values.
DOTBOT_VERSION="1.24.1"
DOTBOT_SHA256="a6d76053156863fd4d85a09fc7f0be8690d78bf4541d629f4ec0471daac2c7b6"
DOTBOT_URL="https://github.com/anishathalye/dotbot/archive/refs/tags/v${DOTBOT_VERSION}.tar.gz"
DOTBOT_CACHE="$SCRIPTPATH/.cache/dotbot"
DOTBOT_DIR="$DOTBOT_CACHE/dotbot-$DOTBOT_VERSION"
DOTBOT_ARCHIVE="$DOTBOT_CACHE/dotbot-${DOTBOT_VERSION}.tar.gz"

GREEN=2
CYAN=6

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

echo_error() {
	printf "   "
	set_color 1
	printf "✗ %s" "$1"
	reset_color
	printf "\n"
}

ensure_dotbot() {
	if [ -x "$DOTBOT_DIR/bin/dotbot" ]; then
		return 0
	fi
	mkdir -p "$DOTBOT_CACHE"
	echo_section "📦 Bootstrapping Dotbot..."
	if ! curl -fsSL "$DOTBOT_URL" -o "${DOTBOT_ARCHIVE}.tmp" 2>/dev/null; then
		echo_error "Failed to download Dotbot"
		return 1
	fi
	# Verify SHA256 — fail closed on mismatch
	ACTUAL_SHA256=$(shasum -a 256 "${DOTBOT_ARCHIVE}.tmp" | awk '{print $1}')
	if [ "$ACTUAL_SHA256" != "$DOTBOT_SHA256" ]; then
		echo_error "Dotbot checksum mismatch (expected $DOTBOT_SHA256, got $ACTUAL_SHA256)"
		rm -f "${DOTBOT_ARCHIVE}.tmp"
		return 1
	fi
	mv -f "${DOTBOT_ARCHIVE}.tmp" "$DOTBOT_ARCHIVE"
	rm -rf "$DOTBOT_DIR"
	if ! tar -xzf "$DOTBOT_ARCHIVE" -C "$DOTBOT_CACHE"; then
		echo_error "Failed to extract Dotbot"
		return 1
	fi
	if [ ! -x "$DOTBOT_DIR/bin/dotbot" ]; then
		echo_error "Dotbot binary not found after extraction"
		return 1
	fi
	echo_success "Dotbot $DOTBOT_VERSION bootstrapped"
}

run_dotbot() {
	if [ ! -f "$SCRIPTPATH/install.conf.yaml" ]; then
		echo_error "install.conf.yaml not found"
		return 1
	fi

	"$DOTBOT_DIR/bin/dotbot" \
		-d "$SCRIPTPATH" \
		-c "$SCRIPTPATH/install.conf.yaml" \
		"$@"
}

if [ -z "${TERM:-}" ] || ! infocmp "$TERM" >/dev/null 2>&1; then
	export TERM=xterm-256color
fi

ensure_dotbot || exit 1

run_dotbot "$@"
DOTBOT_STATUS=$?
if [ $DOTBOT_STATUS -ne 0 ] || [ "$#" -gt 0 ]; then
	exit $DOTBOT_STATUS
fi

# =============================================================================
# Done
# =============================================================================
echo_section "✨ Done! Open vim/neovim to install plugins."
echo ""
