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

# Counters for summary output
DOWNLOAD_COUNT=0
DOWNLOAD_SKIP=0
LINK_COUNT=0
LINK_SKIP=0

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

LINK_FAIL=0

link_file_quiet() {
	if ! mkdir -p "$(dirname "$2")" 2>/dev/null; then
		LINK_FAIL=$((LINK_FAIL + 1))
		return 1
	fi
	if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
		LINK_SKIP=$((LINK_SKIP + 1))
	else
		if ln -sfn "$1" "$2" 2>/dev/null; then
			LINK_COUNT=$((LINK_COUNT + 1))
		else
			LINK_FAIL=$((LINK_FAIL + 1))
		fi
	fi
}

make_dir_quiet() {
	mkdir -p "$1"
}

reset_link_counters() {
	LINK_COUNT=0
	LINK_SKIP=0
	LINK_FAIL=0
}

print_link_summary() {
	if [ $LINK_FAIL -gt 0 ]; then
		echo_warn "Some symlinks failed ($LINK_FAIL failed, $LINK_COUNT created)"
	elif [ $LINK_COUNT -gt 0 ] && [ $LINK_SKIP -gt 0 ]; then
		echo_success "Created $LINK_COUNT symlinks ($LINK_SKIP unchanged)"
	elif [ $LINK_COUNT -gt 0 ]; then
		echo_success "Created $LINK_COUNT symlinks"
	elif [ $LINK_SKIP -gt 0 ]; then
		echo_success "All symlinks exist"
	fi
	reset_link_counters
}

# Safety check: If current TERM's terminfo doesn't exist, use xterm-256color
if ! infocmp "$TERM" >/dev/null 2>&1; then
	export TERM=xterm-256color
fi

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
# Symlinks
# =============================================================================
echo_section "🔗 Creating symlinks..."

# General config files
link_file_quiet "$SCRIPTPATH/.inputrc" "$HOME/.inputrc"
link_file_quiet "$SCRIPTPATH/.lesskey" "$HOME/.lesskey"
link_file_quiet "$SCRIPTPATH/.tern-config" "$HOME/.tern-config"
link_file_quiet "$SCRIPTPATH/.tmux.conf" "$HOME/.tmux.conf"
link_file_quiet "$SCRIPTPATH/.markdownlintrc" "$HOME/.markdownlintrc"
link_file_quiet "$SCRIPTPATH/USER_PREFERENCES.md" "$HOME/.claude/CLAUDE.md"
# USER_PREFERENCES.md symlinks for cross-agent compatibility
link_file_quiet "$SCRIPTPATH/USER_PREFERENCES.md" "$HOME/.codex/AGENTS.md"
link_file_quiet "$SCRIPTPATH/USER_PREFERENCES.md" "$HOME/.gemini/GEMINI.md"
link_file_quiet "$SCRIPTPATH/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_file_quiet "$SCRIPTPATH/wezterm" "$HOME/.config/wezterm"

# Vim
link_file_quiet "$SCRIPTPATH/init-vim.vim" "$HOME/.vimrc"
link_file_quiet "$SCRIPTPATH/init-gvim.vim" "$HOME/.gvimrc"
link_file_quiet "$SCRIPTPATH/ftplugin" "$HOME/.vim/ftplugin"
link_file_quiet "$SCRIPTPATH/vimconfig" "$HOME/.vim/vimconfig"

# Neovim
link_file_quiet "$SCRIPTPATH/nvim/init.lua" "$HOME/.config/nvim/init.lua"
link_file_quiet "$SCRIPTPATH/ftplugin" "$HOME/.config/nvim/ftplugin"
link_file_quiet "$SCRIPTPATH/vimconfig" "$HOME/.config/nvim/vimconfig"
link_file_quiet "$SCRIPTPATH/nvim/plugins" "$HOME/.config/nvim/plugins"
link_file_quiet "$SCRIPTPATH/nvim/config" "$HOME/.config/nvim/config"
link_file_quiet "$SCRIPTPATH/nvim/util" "$HOME/.config/nvim/util"

print_link_summary

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
# Done
# =============================================================================
echo_section "✨ Done! Open vim/neovim to install plugins."
echo ""
