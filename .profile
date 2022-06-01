# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH"


###############################################

# vim
export EDITOR='vim'

# Really long bash histories
export HISTSIZE='9999'

# Safety
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"

# Grep colors
export GREP_COLOR='6;31'
export GREP_OPTIONS='--color=auto'

# Force colors
export CLICOLOR_FORCE=1

# LS Colors
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# LESS
export LESS="-RMS"

# Config files
export XDG_CONFIG_HOME="$HOME/.config"

if [ -n "$ZSH_VERSION" ]; then
  export SCRIPT_SOURCE=$0:h:P
  source "$SCRIPT_SOURCE/git-completion.zsh"

  export ZSH_THEME="steeef"
else
  export SCRIPT_SOURCE=$(dirname $BASH_SOURCE)
  source "$SCRIPT_SOURCE/git-completion.bash"
  source "$SCRIPT_SOURCE/.bash_prompt"

  # Bash Autocomplete
  shopt -s no_empty_cmd_completion

  # Configuration
  shopt -s cdspell 2> /dev/null
  shopt -s nocaseglob 2> /dev/null
  shopt -s histappend 2> /dev/null
  shopt -s autocd 2> /dev/null
  shopt -s globstar 2> /dev/null
fi


# My aliases
alias ls='ls -alFh'
alias ll='ls'
alias l='ls'
alias d='du -hs'
alias v='vim'
alias vi='vim'
alias v.='vim .'
alias n='nvim'
alias n.='nvim .'
alias c='clear'
alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'
alias ........='cd ../../../..'
alias ..........='cd ../../../../..'
alias rebash='source ~/.profile'
alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'
alias psg="ps ax | grep -v ' grep ' | grep"
alias su='su -m'

# Vim commands
alias rmswaps='rm -rf ~/.vim/swaps/* && echo "Removed vim swap files!"'

# git commands
alias st='git status -s'
alias com='git commit -m'
alias cam='git commit -m'
alias caam='git commit --amend --no-edit'
alias co='git checkout'
alias dif='git diff'
alias difc='git diff HEAD~ HEAD'
alias difs='git diff --staged'
alias difb='git diff `git merge-base master HEAD`'
alias add='git add'
alias pushme='git push origin HEAD'
alias pushmef='git push -f origin HEAD'
alias reb='git rebase'
alias lg="git log --graph --pretty=format:'%C(yellow)%h%Creset %C(bold blue)[%an]%Creset %C(magenta)%ar%Creset %C(black):%Creset %s%Cred%d%Creset' --abbrev-commit"
alias lgh="git log --graph --pretty=format:'%C(yellow)%h%Creset %C(bold blue)[%an]%Creset %C(magenta)%ar%Creset %C(black):%Creset %s%Cred%d%Creset' --abbrev-commit --max-count=10 | cat && echo"
alias gg='git grep'
alias blame='git blame -w'

# Completion for the above
__git_complete st _git_status
__git_complete co _git_checkout
__git_complete dif _git_diff
__git_complete difs _git_diff
__git_complete add _git_add
__git_complete reb _git_rebase
__git_complete lg _git_log
__git_complete gg _git_grep
__git_complete com _git_commit
__git_complete cam _git_commit
__git_complete caam _git_commit

# Completion
command -v complete >/dev/null 2>&1 && (

	# SSH Completion
	[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

	# Add `killall` tab completion for common apps
	complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall
)

