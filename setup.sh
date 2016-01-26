#!/bin/bash

set -e

echo "Setting up bash_profile..."

echo "\nsource $SCRIPTPATH/.profile" >> ~/.bash_profile
source ~/.bash_profile

echo "Setting up files..."

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
	> git-prompt.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
	> git-completion.bash
curl https://raw.githubusercontent.com/Valloric/ycmd/master/cpp/ycm/.ycm_extra_conf.py \
	> .ycm_extra_conf.py

echo "Creating aliases..."

SCRIPTPATH=$(pwd -P)

ln -s ~/.vimrc "$SCRIPTPATH/.vimrc"
ln -s ~/.gvimrc "$SCRIPTPATH/.gvimrc"
ln -s ~/.inputrc "$SCRIPTPATH/.inputrc"
ln -s ~/.ycm_extra_conf.py "$SCRIPTPATH/.ycm_extra_conf.py"
ln -s ~/.tern-config "$SCRIPTPATH/.tern-config"

echo "Setting up vim..."

mkdir -p ~/.vim

echo "Setting up neovim aliases..."

mkdir -p $XDG_CONFIG_HOME
ln -s ~/.vim $XDG_CONFIG_HOME/nvim
ln -s ~/.vimrc $XDG_CONFIG_HOME/nvim/init.vim

echo "To finish, open vim and run :PlugInstall"

