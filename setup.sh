#!/bin/bash

echo_message() {
	tput setaf 6 && printf "\n => "
	tput setaf 3 && printf "$@\n"
	tput sgr0
}

echo_task() {
	tput setaf 6 && printf "\n => "
	tput setaf 2 && printf "$@\n"
	tput sgr0
}

set -e

SCRIPTPATH=$(pwd -P)

echo_message "Directory with scripts is $SCRIPTPATH"

echo_task "Setting up bash_profile..."

if ! [ -f ~/.bash_profile ] || ! ( grep -Fxq "source $SCRIPTPATH/.profile" ~/.bash_profile ); then
	echo "\nsource $SCRIPTPATH/.profile\n" >> ~/.bash_profile
	source ~/.bash_profile
fi

echo_task "Setting up files..."

curl -# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
	> git-prompt.bash

curl -# https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
	> git-completion.bash

curl -# https://raw.githubusercontent.com/Valloric/ycmd/master/cpp/ycm/.ycm_extra_conf.py \
	> .ycm_extra_conf.py

echo_task "Creating aliases..."

ln -svf "$SCRIPTPATH/.vimrc" "$HOME/.vimrc"
ln -svf "$SCRIPTPATH/.gvimrc" "$HOME/.gvimrc"
ln -svf "$SCRIPTPATH/.inputrc" "$HOME/.inputrc"
ln -svf "$SCRIPTPATH/.ycm_extra_conf.py" "$HOME/.ycm_extra_conf.py"
ln -svf "$SCRIPTPATH/.tern-config" "$HOME/.tern-config"

echo_task "Setting up vim..."

mkdir -p ~/.vim

echo_task "Setting up neovim aliases..."

mkdir -p $XDG_CONFIG_HOME
ln -svf "$HOME/.vim" "$XDG_CONFIG_HOME/nvim"
ln -svf "$HOME/.vimrc" "$XDG_CONFIG_HOME/nvim/init.vim"

echo_message "To finish, open vim and run :PlugInstall"

