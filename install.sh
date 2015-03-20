
set -e

# Set up Vim
echo "Setting up Vim..."
echo ""

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

