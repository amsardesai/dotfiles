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

set -e

echo_info "Directory with scripts is $SCRIPTPATH"

echo_task "Setting up files..."

download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" git-prompt.bash
download_file "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" git-completion.bash
download_file "https://raw.githubusercontent.com/Valloric/ycmd/master/cpp/ycm/.ycm_extra_conf.py" .ycm_extra_conf.py

echo_task "Setting up bash_profile..."

if ! [ -f ~/.bash_profile ] || ! ( grep -Fxq "source $SCRIPTPATH/.profile" ~/.bash_profile ); then
	echo_message "Adding source script to bash profile"
	echo "" >> ~/.bash_profile
	echo "# Source Ankit's profile" >> ~/.bash_profile
	echo "source $SCRIPTPATH/.profile" >> ~/.bash_profile
	echo "" >> ~/.bash_profile
	source ~/.bash_profile
fi

echo_task "Creating aliases..."

link_file "$SCRIPTPATH/.vimrc" "$HOME/.vimrc"
link_file "$SCRIPTPATH/.gvimrc" "$HOME/.gvimrc"
link_file "$SCRIPTPATH/.inputrc" "$HOME/.inputrc"
link_file "$SCRIPTPATH/.ycm_extra_conf.py" "$HOME/.ycm_extra_conf.py"
link_file "$SCRIPTPATH/.tern-config" "$HOME/.tern-config"
link_file "$SCRIPTPATH/.tmux.conf" "$HOME/.tmux.conf"

echo_task "Setting up vim..."

make_dir ~/.vim

echo_task "Setting up neovim aliases..."

make_dir $XDG_CONFIG_HOME/nvim/
link_file "$HOME/.vimrc" "$XDG_CONFIG_HOME/nvim/init.vim"

echo_info "To finish, open vim and/or neovim and it should set up itself."

