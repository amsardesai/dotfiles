#!/bin/bash

SCRIPTPATH=$(pwd -P)
NPM_PACKAGES="typescript-language-server typescript vscode-langservers-extracted vim-language-server"

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

link_file_quiet() {
    mkdir -p "$(dirname "$2")"
    if [ -L "$2" ] && [ "$(readlink "$2")" = "$1" ]; then
        LINK_SKIP=$((LINK_SKIP + 1))
    else
        ln -sfn "$1" "$2"
        LINK_COUNT=$((LINK_COUNT + 1))
    fi
}

make_dir_quiet() {
    mkdir -p "$1"
}

reset_link_counters() {
    LINK_COUNT=0
    LINK_SKIP=0
}

print_link_summary() {
    if [ $LINK_COUNT -gt 0 ] && [ $LINK_SKIP -gt 0 ]; then
        echo_success "Created $LINK_COUNT symlinks ($LINK_SKIP unchanged)"
    elif [ $LINK_COUNT -gt 0 ]; then
        echo_success "Created $LINK_COUNT symlinks"
    elif [ $LINK_SKIP -gt 0 ]; then
        echo_success "All symlinks exist"
    fi
    reset_link_counters
}

set -e

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

        if [ -f "$SCRIPTPATH/Brewfile" ]; then
            echo_success "Installing Brewfile packages..."
            if brew bundle --file="$SCRIPTPATH/Brewfile" --no-lock >/dev/null 2>&1; then
                echo_success "Brewfile packages installed"
            else
                echo_warn "Some Brewfile packages failed (run 'brew bundle' manually for details)"
            fi
        fi
    else
        echo_warn "Homebrew not found (skipping Brewfile)"
    fi
fi

# =============================================================================
# Dependencies
# =============================================================================
echo_section "🔍 Checking dependencies..."

if node -e "process.exit(0)" 2>/dev/null; then
    echo_success "Node.js found"
else
    echo_error "Node.js not found"
    exit 1
fi

if npm list -g $NPM_PACKAGES >/dev/null 2>&1; then
    echo_success "npm packages installed"
else
    echo_success "Installing npm packages..."
    npm install -g $NPM_PACKAGES >/dev/null 2>&1
    echo_success "npm packages installed"
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

if ! [ -f ~/.bash_profile ] || ! grep -Fxq "Source Ankit's profile" ~/.bash_profile 2>/dev/null; then
    echo "" >> ~/.bash_profile
    echo "# Source Ankit's profile" >> ~/.bash_profile
    echo "source $SCRIPTPATH/.profile" >> ~/.bash_profile
    echo "" >> ~/.bash_profile
    SHELL_UPDATED=$((SHELL_UPDATED + 1))
fi

if ! [ -f ~/.zshrc ] || ! grep -Fxq "Source Ankit's zshrc" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Source Ankit's zshrc" >> ~/.zshrc
    echo "source $SCRIPTPATH/.zshrc" >> ~/.zshrc
    echo "" >> ~/.zshrc
    SHELL_UPDATED=$((SHELL_UPDATED + 1))
fi

if [ $SHELL_UPDATED -gt 0 ]; then
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
link_file_quiet "$SCRIPTPATH/.tern-config" "$HOME/.tern-config"
link_file_quiet "$SCRIPTPATH/.tmux.conf" "$HOME/.tmux.conf"
link_file_quiet "$SCRIPTPATH/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link_file_quiet "$SCRIPTPATH/kitty.conf" "$HOME/.config/kitty/kitty.conf"
link_file_quiet "$SCRIPTPATH/wezterm" "$HOME/.config/wezterm"

# Vim
link_file_quiet "$SCRIPTPATH/init-vim.vim" "$HOME/.vimrc"
link_file_quiet "$SCRIPTPATH/init-gvim.vim" "$HOME/.gvimrc"
link_file_quiet "$SCRIPTPATH/ftplugin" "$HOME/.vim/ftplugin"
link_file_quiet "$SCRIPTPATH/vimconfig" "$HOME/.vim/vimconfig"

# Neovim
link_file_quiet "$SCRIPTPATH/init-nvim.vim" "$HOME/.config/nvim/init.vim"
link_file_quiet "$SCRIPTPATH/ftplugin" "$HOME/.config/nvim/ftplugin"
link_file_quiet "$SCRIPTPATH/vimconfig" "$HOME/.config/nvim/vimconfig"

print_link_summary

# =============================================================================
# Git Configuration
# =============================================================================
echo_section "⚙️  Configuring git..."

GIT_UPDATED=0

if ! [ -f ~/.gitconfig ]; then
    touch ~/.gitconfig
    GIT_UPDATED=$((GIT_UPDATED + 1))
fi

if ! grep -q "path = $SCRIPTPATH/.gitconfig" ~/.gitconfig 2>/dev/null; then
    echo "" >> ~/.gitconfig
    echo "[include]" >> ~/.gitconfig
    echo "	path = $SCRIPTPATH/.gitconfig" >> ~/.gitconfig
    echo "" >> ~/.gitconfig
    GIT_UPDATED=$((GIT_UPDATED + 1))
fi

if [ $GIT_UPDATED -gt 0 ]; then
    echo_success "Git configured"
else
    echo_success "Git already configured"
fi

# =============================================================================
# Done
# =============================================================================
echo_section "✨ Done! Open vim/neovim to install plugins."
echo ""
