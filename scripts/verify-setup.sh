#!/bin/bash
# =============================================================================
# SETUP VERIFICATION SCRIPT
# =============================================================================
#
# Cheap, static, read-only safety checks for the dotfiles setup.
# No network access. No system mutations.
#
# Run before and after any migration step to confirm nothing is broken.
# Exits non-zero if any hard check fails.
#
# Usage: ./scripts/verify-setup.sh
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"

# Colors
GREEN=2
YELLOW=3
RED=1
CYAN=6

echo_section() {
	printf "\n"
	tput setaf $CYAN && printf "%s" "$1"
	tput sgr0 && printf "\n"
}

echo_success() {
	printf "   "
	tput setaf $GREEN && printf "✓ %s" "$1"
	tput sgr0 && printf "\n"
}

echo_warn() {
	printf "   "
	tput setaf $YELLOW && printf "⚠ %s" "$1"
	tput sgr0 && printf "\n"
}

echo_error() {
	printf "   "
	tput setaf $RED && printf "✗ %s" "$1"
	tput sgr0 && printf "\n"
}

FAIL=0

# =============================================================================
# Bash Syntax Checks
# =============================================================================
echo_section "🔍 Checking bash syntax..."

check_bash_syntax() {
	local file="$1"
	if bash -n "$file" 2>/dev/null; then
		echo_success "$(basename "$file")"
	else
		echo_error "Syntax error in $(basename "$file")"
		bash -n "$file"
		FAIL=1
	fi
}

check_bash_syntax "$DOTFILES_DIR/setup.sh"
check_bash_syntax "$DOTFILES_DIR/clean.sh"
check_bash_syntax "$DOTFILES_DIR/scripts/verify-setup.sh"
check_bash_syntax "$DOTFILES_DIR/scripts/claude-statusline.sh"
check_bash_syntax "$DOTFILES_DIR/scripts/claude-stop-hook.sh"

# Check task scripts if they exist (populated in later phases)
if ls "$DOTFILES_DIR/setup/tasks/"*.sh 2>/dev/null | grep -q .; then
	for task in "$DOTFILES_DIR/setup/tasks/"*.sh; do
		check_bash_syntax "$task"
	done
fi

# =============================================================================
# Required Config Files
# =============================================================================
echo_section "📋 Checking required config files..."

REQUIRED_FILES=(
	"Brewfile"
	"npm-global-packages.txt"
	"claude-settings.json"
	"claude-mcp.json"
	"codex-mcp.toml"
	"codex-rules/default.rules"
)

for file in "${REQUIRED_FILES[@]}"; do
	if [ -f "$DOTFILES_DIR/$file" ]; then
		echo_success "$file"
	else
		echo_error "Missing required file: $file"
		FAIL=1
	fi
done

# =============================================================================
# Symlink Source Files
# =============================================================================
echo_section "🔗 Checking symlink sources..."

# All sources referenced in setup.sh link_file_quiet calls
SYMLINK_SOURCES=(
	".inputrc"
	".lesskey"
	".tern-config"
	".tmux.conf"
	".markdownlintrc"
	"USER_PREFERENCES.md"
	"kitty.conf"
	"wezterm"
	"init-vim.vim"
	"init-gvim.vim"
	"ftplugin"
	"vimconfig"
	"nvim/init.lua"
	"nvim/plugins"
	"nvim/config"
	"nvim/util"
)

for src in "${SYMLINK_SOURCES[@]}"; do
	if [ -e "$DOTFILES_DIR/$src" ]; then
		echo_success "$src"
	else
		echo_error "Missing symlink source: $src"
		FAIL=1
	fi
done

# =============================================================================
# Accidental Secrets Check
# =============================================================================
echo_section "🔐 Checking for accidental secrets..."

# Only scan files tracked by git (skips .cache/, node_modules, etc.)
SECRETS_FOUND=0

# AWS Access Key pattern
if git -C "$DOTFILES_DIR" grep -lE "AKIA[A-Z0-9]{16}" -- ':!*.md' 2>/dev/null | grep -q .; then
	echo_error "Possible AWS access key found"
	git -C "$DOTFILES_DIR" grep -lE "AKIA[A-Z0-9]{16}" -- ':!*.md'
	SECRETS_FOUND=1
fi

# GitHub token pattern
if git -C "$DOTFILES_DIR" grep -lE "ghp_[a-zA-Z0-9]{36}" 2>/dev/null | grep -q .; then
	echo_error "Possible GitHub token found"
	git -C "$DOTFILES_DIR" grep -lE "ghp_[a-zA-Z0-9]{36}"
	SECRETS_FOUND=1
fi

# .env files staged or tracked
if git -C "$DOTFILES_DIR" ls-files | grep -q "\.env$"; then
	echo_error ".env file is tracked by git"
	git -C "$DOTFILES_DIR" ls-files | grep "\.env$"
	SECRETS_FOUND=1
fi

if [ $SECRETS_FOUND -eq 0 ]; then
	echo_success "No obvious secrets detected"
else
	FAIL=1
fi

# =============================================================================
# Shellcheck (optional — warns if unavailable)
# =============================================================================
echo_section "🐚 Running shellcheck..."

if command -v shellcheck &>/dev/null; then
	SHELLCHECK_FAIL=0
	for script in \
		"$DOTFILES_DIR/setup.sh" \
		"$DOTFILES_DIR/clean.sh" \
		"$DOTFILES_DIR/scripts/claude-stop-hook.sh"; do
		if shellcheck -x -S warning "$script" 2>/dev/null; then
			echo_success "shellcheck: $(basename "$script")"
		else
			echo_warn "shellcheck warnings in $(basename "$script") (see above)"
			SHELLCHECK_FAIL=1
		fi
	done
	# claude-statusline.sh intentionally uses bash-isms; use bash dialect
	if shellcheck -x -S warning --shell=bash "$DOTFILES_DIR/scripts/claude-statusline.sh" 2>/dev/null; then
		echo_success "shellcheck: claude-statusline.sh"
	else
		echo_warn "shellcheck warnings in claude-statusline.sh (see above)"
		SHELLCHECK_FAIL=1
	fi
	if [ $SHELLCHECK_FAIL -eq 0 ]; then
		echo_success "All scripts passed shellcheck"
	fi
else
	echo_warn "shellcheck not found (install via Brewfile to enable)"
fi

# =============================================================================
# install.conf.yaml Syntax (optional — only if file exists, added in Phase 1)
# =============================================================================
if [ -f "$DOTFILES_DIR/install.conf.yaml" ]; then
	echo_section "📦 Checking install.conf.yaml..."
	if python3 -c "import yaml" 2>/dev/null; then
		if python3 -c "import yaml, sys; yaml.safe_load(sys.stdin)" <"$DOTFILES_DIR/install.conf.yaml" 2>/dev/null; then
			echo_success "install.conf.yaml is valid YAML"
		else
			echo_error "install.conf.yaml has YAML syntax errors"
			python3 -c "import yaml, sys; yaml.safe_load(sys.stdin)" <"$DOTFILES_DIR/install.conf.yaml"
			FAIL=1
		fi
	else
		echo_warn "pyyaml not available — skipping YAML validation"
	fi
fi

# =============================================================================
# Result
# =============================================================================
printf "\n"
if [ $FAIL -eq 0 ]; then
	tput setaf $GREEN && printf "✓ All checks passed\n"
	tput sgr0
	exit 0
else
	tput setaf $RED && printf "✗ One or more checks failed\n"
	tput sgr0
	exit 1
fi
