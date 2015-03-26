#!/bin/bash

set -e

# Set up Vim
echo "Setting up Vim..."
echo ""

if [ ! -d "~/.vim" ]; then
	echo " -> Vundle"
	echo ""

	mkdir -p ~/.vim/bundle
	mkdir -p ~/.vim/swaps
	mkdir -p ~/.vim/backups
	mkdir -p ~/.vim/undo

	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	vim -c PluginInstall -c quitall

	echo " -> YouCompleteMe"
	echo ""

	~/.vim/bundle/YouCompleteMe/install.sh
fi

echo "Creating aliases..."

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

ln -s ~/.vimrc "$SCRIPTPATH/.vimrc"
ln -s ~/.inputrc "$SCRIPTPATH/.inputrc"
ln -s ~/.ycm_extra_conf.py "$SCRIPTPATH/.ycm_extra_conf.py"


