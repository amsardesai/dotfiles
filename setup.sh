#!/bin/bash
# =============================================================================
# DOTFILES SETUP SCRIPT
# =============================================================================
#
# IMPORTANT: This script MUST be idempotent (deterministic).
#
# Running this script 1 time or 1000 times MUST produce the same result.
# Every operation must check if work is needed before making changes:
#   - Downloads: Skip if file exists
#   - Symlinks: Skip if link already points to correct target
#   - Shell config: Skip if source line already present (use substring match!)
#   - Git config: Skip if include path already present
#
# When adding new operations, ALWAYS:
#   1. Check if the operation has already been done
#   2. Only perform the operation if needed
#   3. Use idempotent commands (ln -sfn, mkdir -p, etc.)
#
# NEVER:
#   - Append to files without checking if content exists (use grep -Fq, NOT -Fxq)
#   - Assume the script is running for the first time
#   - Use commands that fail if run twice
#
# =============================================================================

SCRIPTPATH=$(pwd -P)

# Dotbot bootstrap constants
# To update: download the new release, run `shasum -a 256 <archive>`, update both values.
DOTBOT_VERSION="1.24.1"
DOTBOT_SHA256="a6d76053156863fd4d85a09fc7f0be8690d78bf4541d629f4ec0471daac2c7b6"
DOTBOT_URL="https://github.com/anishathalye/dotbot/archive/refs/tags/v${DOTBOT_VERSION}.tar.gz"
DOTBOT_CACHE="$SCRIPTPATH/.cache/dotbot"
DOTBOT_DIR="$DOTBOT_CACHE/dotbot-$DOTBOT_VERSION"
DOTBOT_ARCHIVE="$DOTBOT_CACHE/dotbot-${DOTBOT_VERSION}.tar.gz"

# Colors
GREEN=2
YELLOW=3
CYAN=6

echo_section() {
	printf "\n"
	tput setaf $CYAN && printf "$1"
	tput sgr0 && printf "\n"
}

echo_success() {
	printf "   "
	tput setaf $GREEN && printf "✓ $1"
	tput sgr0 && printf "\n"
}

echo_warn() {
	printf "   "
	tput setaf $YELLOW && printf "⚠ $1"
	tput sgr0 && printf "\n"
}

echo_error() {
	printf "   "
	tput setaf 1 && printf "✗ $1"
	tput sgr0 && printf "\n"
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
	tar -xzf "$DOTBOT_ARCHIVE" -C "$DOTBOT_CACHE"
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

# Safety check: If current TERM's terminfo doesn't exist, use xterm-256color
if ! infocmp "$TERM" >/dev/null 2>&1; then
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
