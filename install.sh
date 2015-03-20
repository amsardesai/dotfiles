
set -e

# Set up Brew if we're in linux
# if [[ "$OSTYPE" == "linux-gnu" ]]; then
  # tput setaf 1; echo "Setting up Homebrew for Linux..."; tput sgr0
  # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/linuxbrew/go/install)"
  # ~/.linuxbrew/bin/brew update
  # ~/.linuxbrew/bin/brew upgrade
  # ~/.linuxbrew/bin/brew install cmake vim git
# fi

# Set up Vim
tput setaf 1; echo "Setting up Vim..."; tput sgr0

tput setaf 1; echo " -> Vundle"; tput sgr0
mkdir -p ~/.vim/bundle
git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c PluginInstall -c quitall

tput setaf 1; echo " -> YouCompleteMe"; tput sgr0
~/.vim/bundle/YouCompleteMe/install.sh

