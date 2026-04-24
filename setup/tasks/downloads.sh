#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

DOWNLOAD_COUNT=0
DOWNLOAD_SKIP=0

download_file_quiet() {
	if [ -f "$2" ]; then
		DOWNLOAD_SKIP=$((DOWNLOAD_SKIP + 1))
		return 0
	fi

	if curl -fsSL "$1" -o "$2" 2>/dev/null && [ -s "$2" ]; then
		DOWNLOAD_COUNT=$((DOWNLOAD_COUNT + 1))
		return 0
	fi

	rm -f "$2"
	return 1
}

echo_section "📦 Setting up files..."

download_file_quiet "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh" "$DOTFILES_DIR/git-prompt.bash"
download_file_quiet "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash" "$DOTFILES_DIR/git-completion.bash"
download_file_quiet "https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh" "$DOTFILES_DIR/git-completion.zsh"

if [ $DOWNLOAD_COUNT -gt 0 ]; then
	echo_success "Downloaded $DOWNLOAD_COUNT git completion files"
elif [ $DOWNLOAD_SKIP -gt 0 ]; then
	echo_success "Git completion files exist"
fi
