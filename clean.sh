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

delete_file() {
	printf "    "
	tput setaf $COLOR_MESSAGE && printf "Deleting "
	tput sgr0 && printf "$1\n"
	rm -rf $1
}

set -e

echo_info "Directory with scripts is $SCRIPTPATH"

echo_task "Cleaning this folder..."

( cd "$SCRIPTPATH" && git clean -Xf )

echo_task "Deleting symlinks..."

delete_file "$HOME/.vimrc"
delete_file "$HOME/.gvimrc"
delete_file "$HOME/.inputrc"
delete_file "$HOME/.tern-config"
delete_file "$HOME/.tmux.conf"

echo_task "Deleting vim stuff..."

delete_file "$HOME/.vim"

echo_task "Deleting neovim stuff..."

export XDG_CONFIG_HOME="$HOME/.config"
delete_file "$XDG_CONFIG_HOME/nvim"

echo_task "Don't forget to remove the 'source' line from the bash profile."
echo_task "Resetting bash in 2 seconds..."

sleep 2

clear
exec bash -l

