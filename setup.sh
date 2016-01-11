#!/bin/bash

set -e

echo "Setting up files..."

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh \
	> git-prompt.bash
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash \
	> git-completion.bash
curl https://raw.githubusercontent.com/Valloric/ycmd/master/cpp/ycm/.ycm_extra_conf.py \
	> .ycm_extra_conf.py

echo "Creating aliases..."

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

ln -s ~/.vimrc "$SCRIPTPATH/.vimrc"
ln -s ~/.inputrc "$SCRIPTPATH/.inputrc"
ln -s ~/.ycm_extra_conf.py "$SCRIPTPATH/.ycm_extra_conf.py"

