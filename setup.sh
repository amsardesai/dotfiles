#!/bin/bash

set -e

SCRIPTPATH=$(pwd -P)

echo "Directory with scripts is $SCRIPTPATH"

echo "Setting up bash_profile..."

if ! [ -f ~/.bash_profile ] || ! ( grep -Fxq "source $SCRIPTPATH/.profile" ~/.bash_profile ); then
	echo "\nsource $SCRIPTPATH/.profile\n" >> ~/.bash_profile
	source ~/.bash_profile
fi

echo "Setting up files..."

if ! [ -f "git-prompt.bash" ]; then
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
		> git-prompt.bash
fi

if ! [ -f "git-completion.bash" ]; then
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
		> git-completion.bash
fi

if ! [ -f ".ycm_extra_conf.py" ]; then
	curl https://raw.githubusercontent.com/Valloric/ycmd/master/cpp/ycm/.ycm_extra_conf.py \
		> .ycm_extra_conf.py
fi

echo "Creating aliases..."

ln -sv ~/.vimrc "$SCRIPTPATH/.vimrc"
ln -sv ~/.gvimrc "$SCRIPTPATH/.gvimrc"
ln -sv ~/.inputrc "$SCRIPTPATH/.inputrc"
ln -sv ~/.ycm_extra_conf.py "$SCRIPTPATH/.ycm_extra_conf.py"
ln -sv ~/.tern-config "$SCRIPTPATH/.tern-config"

echo "Setting up vim..."

mkdir -p ~/.vim

echo "Setting up neovim aliases..."

mkdir -p $XDG_CONFIG_HOME/nvim
ln -sv ~/.vim $XDG_CONFIG_HOME/nvim
ln -sv ~/.vimrc $XDG_CONFIG_HOME/nvim/init.vim

echo "To finish, open vim and run :PlugInstall"

