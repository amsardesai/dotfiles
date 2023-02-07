# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="steeef"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git npm)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Safety
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"

# Force colors
export CLICOLOR_FORCE=1

# LS Colors
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# LESS
export LESS="-x2RMS"

# My aliases
alias ls='ls -alFh'
alias ll='ls'
alias l='ls'
alias d='du -hs'
alias v='vim'
alias vi='vim'
alias v.='vim .'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias rebash='source ~/.zshrc'
alias psg="ps ax | grep -v ' grep ' | grep"
alias su='su -m'

# Vim commands
alias rmswaps='rm -rf ~/.vim/swaps/* && echo "Removed vim swap files!"'

# git commands
alias st='git status --short'
alias com='git commit -m'
alias cam='git commit -m'
alias caam='git commit --amend --no-edit'
alias co='git checkout'

alias add='git add'
alias add.='git add .'

alias pullme='git pull origin main'
alias pushme='git push origin HEAD'
alias pushmef='git push -f origin HEAD'
alias pruneme='git remote prune origin'

alias re='git rebase'
alias res='git rebase --skip'
alias rec='git rebase --continue'
alias rea='git rebase --abort'
alias reh='git rebase HEAD'
alias rem='git rebase main'

GIT_DIFF_OPTIONS="--ignore-all-space --minimal --find-copies"
alias dif="git diff $GIT_DIFF_OPTIONS"
alias difc="git diff $GIT_DIFF_OPTIONS HEAD~ HEAD"
alias difs="git diff $GIT_DIFF_OPTIONS --staged"
alias difb="git diff $GIT_DIFF_OPTIONS $(git merge-base origin/main HEAD)"
alias difbl="git --no-pager diff $(git merge-base origin/main HEAD) --stat"

GIT_LOG_OPTIONS="--graph --pretty=format:'%C(yellow)%h%C(reset) %C(italic magenta)%cd%C(reset) %C(bold blue)[%aN]%C(reset) %C(italic)%s%C(reset)%C(auto)%d%C(reset)' --abbrev-commit --date=relative"
alias lg="git --no-pager log $GIT_LOG_OPTIONS --max-count=10"
alias lgh="git log $GIT_LOG_OPTIONS --branches"
alias lgm="git log $GIT_LOG_OPTIONS --author=Ankit"

alias gg='git grep'
alias bl='git blame -w'

alias speedtest='wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip'

export PATH=${PATH}:/opt/homebrew/bin:/opt/homebrew/sbin
export OP_BIOMETRIC_UNLOCK_ENABLED=true

eval "$(rbenv init - zsh)"
eval "$(notion completion --install)"

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools/bin"
