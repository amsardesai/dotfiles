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
NPM_PACKAGES=$(grep -v '^#' "$SCRIPTPATH/npm-global-packages.txt" | grep -v '^$' | tr '\n' ' ')

# Dotbot bootstrap constants
# To update: download the new release, run `shasum -a 256 <archive>`, update both values.
DOTBOT_VERSION="1.24.1"
DOTBOT_SHA256="a6d76053156863fd4d85a09fc7f0be8690d78bf4541d629f4ec0471daac2c7b6"
DOTBOT_URL="https://github.com/anishathalye/dotbot/archive/refs/tags/v${DOTBOT_VERSION}.tar.gz"
DOTBOT_CACHE="$SCRIPTPATH/.cache/dotbot"
DOTBOT_DIR="$DOTBOT_CACHE/dotbot-$DOTBOT_VERSION"
DOTBOT_ARCHIVE="$DOTBOT_CACHE/dotbot-${DOTBOT_VERSION}.tar.gz"

# Counters for summary output
DOWNLOAD_COUNT=0
DOWNLOAD_SKIP=0

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

# Print indented output (for showing progress)
echo_progress() {
	tput setaf 8 && printf "     $1" && tput sgr0 && printf "\n"
}

download_file_quiet() {
	if [ -f "$2" ]; then
		DOWNLOAD_SKIP=$((DOWNLOAD_SKIP + 1))
		return 0
	fi
	if curl -fsSL "$1" -o "$2" 2>/dev/null; then
		if [ -s "$2" ]; then
			DOWNLOAD_COUNT=$((DOWNLOAD_COUNT + 1))
			return 0
		else
			rm -f "$2"
			return 1
		fi
	else
		return 1
	fi
}

make_dir_quiet() {
	mkdir -p "$1"
}

upsert_codex_mcp_sections() {
	SOURCE_FILE="$1"
	DEST_FILE="$2"
	TMP_FILE=$(mktemp)

	if [ -f "$DEST_FILE" ]; then
		awk '
			function is_managed_section(line) {
				return line ~ /^\[mcp_servers\.(chrome-devtools|notion|figma)(\.|])/
			}

			/^\[/ {
				if (is_managed_section($0)) {
					skip = 1
					next
				}
				skip = 0
			}

			!skip { print }
		' "$DEST_FILE" >"$TMP_FILE"
	else
		: >"$TMP_FILE"
	fi

	if [ -s "$TMP_FILE" ]; then
		printf "\n" >>"$TMP_FILE"
	fi
	cat "$SOURCE_FILE" >>"$TMP_FILE"

	if [ -f "$DEST_FILE" ] && cmp -s "$DEST_FILE" "$TMP_FILE"; then
		rm -f "$TMP_FILE"
		return 1
	fi

	mkdir -p "$(dirname "$DEST_FILE")"
	mv -f "$TMP_FILE" "$DEST_FILE"
	chmod 600 "$DEST_FILE" 2>/dev/null || true
	return 0
}

merge_codex_rules() {
	SOURCE_FILE="$1"
	DEST_FILE="$2"
	UPDATED=0

	mkdir -p "$(dirname "$DEST_FILE")"
	touch "$DEST_FILE"

	while IFS= read -r RULE || [ -n "$RULE" ]; do
		[ -z "$RULE" ] && continue

		if ! grep -Fq "$RULE" "$DEST_FILE" 2>/dev/null; then
			printf "%s\n" "$RULE" >>"$DEST_FILE"
			UPDATED=1
		fi
	done <"$SOURCE_FILE"

	return $UPDATED
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

# Safety check: If current TERM's terminfo doesn't exist, use xterm-256color
if ! infocmp "$TERM" >/dev/null 2>&1; then
	export TERM=xterm-256color
fi

ensure_dotbot || echo_warn "Dotbot bootstrap failed (skipping Dotbot tasks)"

# =============================================================================
# Homebrew (macOS)
# =============================================================================
if [[ "$OSTYPE" == "darwin"* ]]; then
	echo_section "🍺 Checking Homebrew..."

	if command -v brew &>/dev/null; then
		echo_success "Homebrew found"

		# Update Homebrew itself
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

		if [ -f "$SCRIPTPATH/Brewfile" ]; then
			echo_success "Running brew bundle..."

			# Capture output first (piping directly can break brew bundle)
			BREW_OUTPUT=$(brew bundle --file="$SCRIPTPATH/Brewfile" 2>&1) || true

			# Show all output (gray, indented)
			echo "$BREW_OUTPUT" | while read -r line; do
				[ -n "$line" ] && echo_progress "$line"
			done

			echo_success "Brewfile complete"
		fi
	else
		echo_warn "Homebrew not found (skipping Brewfile)"
	fi
fi

# =============================================================================
# Dependencies (optional - skipped if tools not available)
# =============================================================================
echo_section "🔍 Checking dependencies..."

if command -v node &>/dev/null && command -v npm &>/dev/null; then
	echo_success "Node.js found"

	if npm list -g $NPM_PACKAGES >/dev/null 2>&1; then
		echo_success "npm packages already installed"
	else
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
	fi
else
	echo_warn "Node.js/npm not found (skipping npm packages)"
fi

# =============================================================================
# Git Completion Files
# =============================================================================
echo_section "📦 Setting up files..."

download_file_quiet "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" git-prompt.bash
download_file_quiet "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" git-completion.bash
download_file_quiet "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh" git-completion.zsh

if [ $DOWNLOAD_COUNT -gt 0 ]; then
	echo_success "Downloaded $DOWNLOAD_COUNT git completion files"
elif [ $DOWNLOAD_SKIP -gt 0 ]; then
	echo_success "Git completion files exist"
fi

# =============================================================================
# WezTerm Terminfo
# =============================================================================
WEZTERM_TERMINFO_URL="https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo"
WEZTERM_TERMINFO_FILE="$SCRIPTPATH/wezterm.terminfo"

if [ -f "$HOME/.terminfo/w/wezterm" ]; then
	echo_success "WezTerm terminfo exists"
else
	# Download if needed
	if [ ! -f "$WEZTERM_TERMINFO_FILE" ]; then
		curl -fsSL "$WEZTERM_TERMINFO_URL" -o "$WEZTERM_TERMINFO_FILE" 2>/dev/null
	fi

	if [ -f "$WEZTERM_TERMINFO_FILE" ] && [ -s "$WEZTERM_TERMINFO_FILE" ]; then
		make_dir_quiet "$HOME/.terminfo"
		if tic -o "$HOME/.terminfo" "$WEZTERM_TERMINFO_FILE" 2>/dev/null; then
			echo_success "WezTerm terminfo compiled"
		else
			echo_warn "WezTerm terminfo failed (using fallback)"
		fi
	else
		echo_warn "WezTerm terminfo download failed (using fallback)"
	fi
fi

# =============================================================================
# Shell Configuration
# =============================================================================
echo_section "🐚 Configuring shell..."

SHELL_UPDATED=0
SHELL_FAILED=0

# Check for existing source line (use -F for literal match, not -x for whole line)
if ! [ -f ~/.bash_profile ] || ! grep -Fq "source $SCRIPTPATH/.profile" ~/.bash_profile 2>/dev/null; then
	if {
		echo ""
		echo "# Source Ankit's profile"
		echo "source $SCRIPTPATH/.profile"
		echo ""
	} >>~/.bash_profile 2>/dev/null; then
		SHELL_UPDATED=$((SHELL_UPDATED + 1))
	else
		SHELL_FAILED=$((SHELL_FAILED + 1))
	fi
fi

# Check for existing source line (use -F for literal match, not -x for whole line)
# IMPORTANT: Must use $SCRIPTPATH (not hardcoded path) to match what we write
if ! [ -f ~/.zshrc ] || ! grep -Fq "source $SCRIPTPATH/.zshrc" ~/.zshrc 2>/dev/null; then
	if {
		echo ""
		echo "# Source Ankit's zshrc"
		echo "source $SCRIPTPATH/.zshrc"
		echo ""
	} >>~/.zshrc 2>/dev/null; then
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

# =============================================================================
# Git Configuration
# =============================================================================
echo_section "⚙️  Configuring git..."

if command -v git &>/dev/null; then
	GIT_UPDATED=0
	GIT_FAILED=0

	if ! [ -f ~/.gitconfig ]; then
		if touch ~/.gitconfig 2>/dev/null; then
			GIT_UPDATED=$((GIT_UPDATED + 1))
		else
			GIT_FAILED=1
		fi
	fi

	if [ $GIT_FAILED -eq 0 ] && ! grep -q "path = $SCRIPTPATH/.gitconfig" ~/.gitconfig 2>/dev/null; then
		if {
			echo ""
			echo "[include]"
			echo "	path = $SCRIPTPATH/.gitconfig"
			echo ""
		} >>~/.gitconfig 2>/dev/null; then
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
else
	echo_warn "Git not found (skipping git config)"
fi

# =============================================================================
# Bat Theme (Tokyo Night)
# =============================================================================
if command -v bat &>/dev/null; then
	BAT_THEMES_DIR="$(bat --config-dir)/themes"
	BAT_THEME_FILE="$BAT_THEMES_DIR/tokyonight_night.tmTheme"

	if [ -f "$BAT_THEME_FILE" ]; then
		echo_success "Bat Tokyo Night theme exists"
	else
		mkdir -p "$BAT_THEMES_DIR"
		if curl -fsSL "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme" -o "$BAT_THEME_FILE" 2>/dev/null; then
			bat cache --build >/dev/null 2>&1
			echo_success "Bat Tokyo Night theme installed"
		else
			echo_warn "Bat theme download failed"
		fi
	fi
fi

# =============================================================================
# Claude Code Settings
# =============================================================================
echo_section "🪄 Configuring AI tools..."

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
REPO_CLAUDE_SETTINGS="$SCRIPTPATH/claude-settings.json"

# Ensure ~/.claude directory exists
mkdir -p "$HOME/.claude"

if [ -f "$REPO_CLAUDE_SETTINGS" ]; then
	# Expand $HOME in the repo settings file
	EXPANDED_SETTINGS=$(envsubst < "$REPO_CLAUDE_SETTINGS")

	if [ -f "$CLAUDE_SETTINGS" ]; then
		# Merge repo settings into existing settings (deep merge)
		MERGED=$(jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" <(echo "$EXPANDED_SETTINGS"))

		# Check if merged result differs from current (idempotency)
		CURRENT_SORTED=$(jq -S '.' "$CLAUDE_SETTINGS")
		MERGED_SORTED=$(echo "$MERGED" | jq -S '.')

		if [ "$CURRENT_SORTED" = "$MERGED_SORTED" ]; then
			echo_success "Claude Code settings already up to date"
		else
			echo "$MERGED" > "$CLAUDE_SETTINGS"
			echo_success "Merged settings into Claude Code config"
		fi
	else
		# Create new settings file
		echo "$EXPANDED_SETTINGS" > "$CLAUDE_SETTINGS"
		echo_success "Created Claude Code settings with hooks"
	fi
else
	echo_warn "claude-settings.json not found in repo"
fi

# =============================================================================
# Claude Code MCP Servers
# =============================================================================

CLAUDE_JSON="$HOME/.claude.json"
REPO_MCP_SETTINGS="$SCRIPTPATH/claude-mcp.json"

if [ -f "$REPO_MCP_SETTINGS" ]; then
	if [ -f "$CLAUDE_JSON" ]; then
		# Deep merge mcpServers into existing file
		CURRENT_MCP=$(jq '.mcpServers // {}' "$CLAUDE_JSON" 2>/dev/null)
		NEW_MCP=$(jq '.mcpServers // {}' "$REPO_MCP_SETTINGS")

		# Check if MCP servers already match
		MERGED_MCP=$(jq -s '.[0] * .[1]' <(echo "$CURRENT_MCP") <(echo "$NEW_MCP"))

		if [ "$CURRENT_MCP" = "$MERGED_MCP" ]; then
			echo_success "MCP servers already configured"
		else
			# Merge into full file preserving all other settings
			MERGED=$(jq --argjson mcp "$MERGED_MCP" '.mcpServers = $mcp' "$CLAUDE_JSON")
			echo "$MERGED" > "$CLAUDE_JSON"
			echo_success "Merged MCP servers into Claude Code config"
		fi
	else
		# Create new file with just mcpServers
		cp -f "$REPO_MCP_SETTINGS" "$CLAUDE_JSON"
		echo_success "Created Claude Code config with MCP servers"
	fi
else
	echo_warn "claude-mcp.json not found in repo"
fi

# =============================================================================
# Codex MCP Servers & Rules
# =============================================================================

CODEX_CONFIG="$HOME/.codex/config.toml"
REPO_CODEX_MCP="$SCRIPTPATH/codex-mcp.toml"
CODEX_RULES="$HOME/.codex/rules/default.rules"
REPO_CODEX_RULES="$SCRIPTPATH/codex-rules/default.rules"

mkdir -p "$HOME/.codex"

if [ -f "$REPO_CODEX_MCP" ]; then
	if upsert_codex_mcp_sections "$REPO_CODEX_MCP" "$CODEX_CONFIG"; then
		echo_success "Merged MCP servers into Codex config"
	else
		echo_success "Codex MCP servers already up to date"
	fi
else
	echo_warn "codex-mcp.toml not found in repo"
fi

if [ -f "$REPO_CODEX_RULES" ]; then
	if merge_codex_rules "$REPO_CODEX_RULES" "$CODEX_RULES"; then
		echo_success "Added default Codex approval rules"
	else
		echo_success "Codex approval rules already up to date"
	fi
else
	echo_warn "codex-rules/default.rules not found in repo"
fi

# =============================================================================
# Done
# =============================================================================
echo_section "✨ Done! Open vim/neovim to install plugins."
echo ""

# =============================================================================
# Dotbot — runs install.conf.yaml after all existing setup is complete.
# Tasks are being migrated from above into install.conf.yaml incrementally.
# In the final state (Phase 4), this will be the only logic in setup.sh.
# =============================================================================
if [ -x "$DOTBOT_DIR/bin/dotbot" ] && [ -f "$SCRIPTPATH/install.conf.yaml" ]; then
	"$DOTBOT_DIR/bin/dotbot" \
		-d "$SCRIPTPATH" \
		-c "$SCRIPTPATH/install.conf.yaml" \
		"$@"
fi
