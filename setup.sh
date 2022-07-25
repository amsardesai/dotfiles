#!/bin/bash

SCRIPTPATH=$(pwd -P)
COLOR_ARROW=6
COLOR_INFO=3
COLOR_TASK=2
COLOR_MESSAGE=5

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
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Downloading file "
	tput sgr0 && printf "$2\n"
	curl -# $1 > $2
}

link_file() {
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Linking file "
	tput sgr0 && printf "$2"
	tput setaf $COLOR_MESSAGE && printf " to "
	tput sgr0 && printf "$1\n"
	ln -sf $1 $2
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

echo_info "Checking for dependencies..."

echo_task "Checking node installation..."
node -e "process.exit(0)"

echo_info "Directory with scripts is $SCRIPTPATH"

echo_task "Setting up files..."

download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" git-prompt.bash
download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" git-completion.bash
download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh" git-completion.zsh

echo_task "Setting up bash_profile..."

if ! [ -f ~/.bash_profile ] || ! ( grep -Fxq "source $SCRIPTPATH/.profile" ~/.bash_profile ); then
	echo_message "Adding source script to bash profile"
	echo "" >> ~/.bash_profile
	echo "# Source Ankit's profile" >> ~/.bash_profile
	echo "source $SCRIPTPATH/.profile" >> ~/.bash_profile
	echo "" >> ~/.bash_profile
fi

echo_task "Creating aliases..."

link_file "$SCRIPTPATH/init.vim" "$HOME/.vimrc"
link_file "$SCRIPTPATH/graphical.vim" "$HOME/.gvimrc"
link_file "$SCRIPTPATH/.inputrc" "$HOME/.inputrc"
link_file "$SCRIPTPATH/.tern-config" "$HOME/.tern-config"
link_file "$SCRIPTPATH/.tmux.conf" "$HOME/.tmux.conf"
link_file "$SCRIPTPATH/.zshrc" "$HOME/.zshrc"

echo_task "Setting up vim..."

make_dir "$HOME/.vim/"
link_file "$SCRIPTPATH/ftplugin" "$HOME/.vim/ftplugin"
link_file "$SCRIPTPATH/config" "$HOME/.vim/config"

echo_info "To finish, open vim and/or neovim and it should set up itself."

