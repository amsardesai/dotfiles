#!/bin/bash

SCRIPTPATH=$(pwd -P)
COLOR_ARROW=6
COLOR_INFO=3
COLOR_TASK=2
COLOR_MESSAGE=5
NPM_PACKAGES="typescript-language-server typescript vscode-langservers-extracted vim-language-server"

echo_info() {
	tput setaf $COLOR_ARROW && printf "\n => "
	tput setaf $COLOR_INFO && printf "$@\n"
	tput sgr0
}

echo_task() {
	tput setaf $COLOR_ARROW && printf "\n => "
	tput setaf $COLOR_TASK && printf "$@\n"
	tput sgr0
}

echo_message() {
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "$@\n"
}

download_file() {
	if [ -f "$2" ]; then
		echo_message "File $2 already exists, skipping..."
		return 0
	fi
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Downloading file "
	tput sgr0 && printf "$2\n"

	# Download with error checking
	if curl -fsSL "$1" -o "$2"; then
		# Verify file has content
		if [ -s "$2" ]; then
			return 0
		else
			echo_message "ERROR: Downloaded file is empty"
			rm -f "$2"
			return 1
		fi
	else
		echo_message "ERROR: curl failed to download $1"
		return 1
	fi
}

link_file() {
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Linking file "
	tput sgr0 && printf "$2"
	tput setaf $COLOR_MESSAGE && printf " to "
	tput sgr0 && printf "$1\n"
	ln -sfn $1 $2
}

make_dir() {
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Creating directory "
	tput sgr0 && printf "$1\n"
	mkdir -p $1
}

copy_dir() {
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Copying to "
	tput sgr0 && printf "$2\n"
	cp -a $1 $2
}

set -e

# Safety check: If current TERM's terminfo doesn't exist, use xterm-256color temporarily
# This prevents "tput: unknown terminal" errors when installing wezterm terminfo
if ! infocmp "$TERM" >/dev/null 2>&1; then
	echo "WARNING: Terminal type '$TERM' not found, using xterm-256color for setup"
	export TERM=xterm-256color
fi

echo_info "Checking for dependencies..."

echo_task "Checking node installation..."
node -e "process.exit(0)"

echo_info "Directory with scripts is $SCRIPTPATH"

echo_task "Checking npm packages..."

# Check if all required packages are already installed
if npm list -g $NPM_PACKAGES >/dev/null 2>&1; then
	echo_message "All npm packages already installed, skipping..."
else
	echo_message "Installing missing npm packages..."
	npm install -g $NPM_PACKAGES
fi

echo_task "Setting up files..."

download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" git-prompt.bash
download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" git-completion.bash
download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh" git-completion.zsh

echo_task "Setting up wezterm terminfo..."

# Download wezterm terminfo file
WEZTERM_TERMINFO_URL="https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo"
WEZTERM_TERMINFO_FILE="$SCRIPTPATH/wezterm.terminfo"

download_file "$WEZTERM_TERMINFO_URL" "$WEZTERM_TERMINFO_FILE"

# Verify download succeeded and file has content
if [ ! -f "$WEZTERM_TERMINFO_FILE" ]; then
    echo_message "ERROR: Failed to download wezterm terminfo file"
    echo_message "Falling back to xterm-256color"
    # Add temporary fallback in shell configs
    export TERM=xterm-256color
elif [ ! -s "$WEZTERM_TERMINFO_FILE" ]; then
    echo_message "ERROR: Downloaded file is empty"
    echo_message "Falling back to xterm-256color"
    export TERM=xterm-256color
else
    # Compile and install terminfo to user directory
    make_dir "$HOME/.terminfo"

    # Show tic errors instead of suppressing them
    if tic -o "$HOME/.terminfo" "$WEZTERM_TERMINFO_FILE"; then
        echo_message "Successfully compiled wezterm terminfo"

        # Verify installation
        if [ -f "$HOME/.terminfo/w/wezterm" ]; then
            echo_message "✓ Verified: ~/.terminfo/w/wezterm installed"
        else
            echo_message "WARNING: tic succeeded but terminfo file not found"
        fi
    else
        echo_message "ERROR: Failed to compile terminfo with tic command"
        echo_message "Falling back to xterm-256color"
        export TERM=xterm-256color
    fi
fi

echo_task "Setting up bash_profile..."

if ! [ -f ~/.bash_profile ] || ! ( grep -Fxq "Source Ankit's profile" ~/.bash_profile ); then
	echo_message "Adding source script to ~/.bash_profile"
	echo "" >> ~/.bash_profile
	echo "# Source Ankit's profile" >> ~/.bash_profile
	echo "source $SCRIPTPATH/.profile" >> ~/.bash_profile
	echo "" >> ~/.bash_profile
fi

if ! [ -f ~/.zshrc ] || ! ( grep -Fxq "Source Ankit's zshrc" ~/.zshrc ); then
	echo_message "Adding source script to ~/.zshrc"
	echo "" >> ~/.zshrc
	echo "# Source Ankit's zshrc" >> ~/.zshrc
	echo "source $SCRIPTPATH/.zshrc" >> ~/.zshrc
	echo "" >> ~/.zshrc
fi

echo_task "⚙️ Creating aliases..."

link_file "$SCRIPTPATH/.inputrc" "$HOME/.inputrc"
link_file "$SCRIPTPATH/.tern-config" "$HOME/.tern-config"
link_file "$SCRIPTPATH/.tmux.conf" "$HOME/.tmux.conf"
make_dir "$HOME/.claude/"
link_file "$SCRIPTPATH/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
make_dir "$HOME/.config/kitty/"
link_file "$SCRIPTPATH/kitty.conf" "$HOME/.config/kitty/kitty.conf"
make_dir "$HOME/.config/"
link_file "$SCRIPTPATH/wezterm" "$HOME/.config/wezterm"

echo_task "📝 Setting up vim..."

link_file "$SCRIPTPATH/vim-init.vim" "$HOME/.vimrc"
link_file "$SCRIPTPATH/gvim-init.vim" "$HOME/.gvimrc"
make_dir "$HOME/.vim/"
link_file "$SCRIPTPATH/ftplugin" "$HOME/.vim/ftplugin"
link_file "$SCRIPTPATH/config" "$HOME/.vim/config"

echo_task "📝 Setting up neovim..."

make_dir "$HOME/.config/nvim/"
link_file "$SCRIPTPATH/nvim-init.vim" "$HOME/.config/nvim/init.vim"
link_file "$SCRIPTPATH/ftplugin" "$HOME/.config/nvim/ftplugin"
link_file "$SCRIPTPATH/config" "$HOME/.config/nvim/config"

echo_task "⚙️ Setting up gitconfig..."

# Create ~/.gitconfig if it doesn't exist
if ! [ -f ~/.gitconfig ]; then
	echo_message "Creating ~/.gitconfig"
	touch ~/.gitconfig
fi

# Check if include directive already exists
if ! grep -q "path = $SCRIPTPATH/.gitconfig" ~/.gitconfig; then
	echo_message "Adding include directive to ~/.gitconfig"
	echo "" >> ~/.gitconfig
	echo "[include]" >> ~/.gitconfig
	echo "	path = $SCRIPTPATH/.gitconfig" >> ~/.gitconfig
	echo "" >> ~/.gitconfig
else
	echo_message "Include directive already exists, skipping..."
fi

echo_info "To finish, open vim and/or neovim and it should set up itself."

