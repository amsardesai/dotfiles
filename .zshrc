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
plugins=(git gitfast npm)

# Disable oh-my-zsh auto-update (saves ~13 seconds on startup)
# Run `omz update` manually when needed
zstyle ':omz:update' mode disabled

source $ZSH/oh-my-zsh.sh

# Trigger git prompt update for Graphite CLI commands
# (steeef theme only updates for git/hub/svn commands by default)
function graphite_preexec {
    case "$2" in
        gt\ *|gt)
            PR_GIT_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec graphite_preexec

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

# Word navigation with Option keys (zsh keybindings)
bindkey "^[[1;3C" forward-word      # Option-Right
bindkey "^[[1;3D" backward-word     # Option-Left
bindkey "^[[1;4C" end-of-line       # Option-Shift-Right
bindkey "^[[1;4D" beginning-of-line # Option-Shift-Left

# Move 20 characters with Option-Ctrl-Arrow
forward-20-chars() { repeat 20 { zle forward-char } }
backward-20-chars() { repeat 20 { zle backward-char } }
zle -N forward-20-chars
zle -N backward-20-chars
bindkey "^[[1;7C" forward-20-chars  # Option-Ctrl-Right
bindkey "^[[1;7D" backward-20-chars # Option-Ctrl-Left

# Export COLUMNS to subprocesses (for Claude Code statusline width detection)
export COLUMNS

# Force colors
export CLICOLOR_FORCE=1

# LS Colors
export CLICOLOR=1
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# My aliases
alias ls='ls -alFh'
alias ll='ls'
alias l='ls'
alias d='du -hs'
# Use vim instead of nvim when inside neovim terminal
if [[ -n "$NVIM" ]]; then
  alias v='vim'
  alias vi='vim'
  alias v.='vim .'
else
  alias v='nvim'
  alias vi='nvim'
  alias v.='nvim .'
fi
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

# Git Add
alias add='git add'
alias add.='git add .'

# Git Branch
alias br='git branch'
alias brd='git branch -D'

# Git Commit
alias com='git commit -m'
alias cam='git commit -m'
alias caam='git commit --amend --no-edit'
alias camn='git commit --no-verify -m'

# Git Checkout
alias co='git checkout'
alias com='git checkout main'
alias detach='git checkout --detach'  # Detach HEAD for worktree flexibility

# Git Diff
GIT_DIFF_OPTIONS="--ignore-all-space --minimal --find-copies"
GIT_DIFF_STAT_OPTIONS="--stat"
alias dif="git diff $GIT_DIFF_OPTIONS"
alias difl="git --no-pager diff $GIT_DIFF_STAT_OPTIONS"
alias difc="git show $GIT_DIFF_OPTIONS HEAD"
alias difcl="git --no-pager diff $GIT_DIFF_STAT_OPTIONS HEAD~ HEAD"
alias difs="git diff $GIT_DIFF_OPTIONS --staged"
alias difsl="git --no-pager diff $GIT_DIFF_STAT_OPTIONS --staged"
alias difm="git diff $GIT_DIFF_OPTIONS main"
alias difml="git --no-pager diff $GIT_DIFF_STAT_OPTIONS main"

# Git Log (modularized - clickable links, HEAD/unpushed markers)
source ~/.dotfiles/zsh/git-log.zsh

# Git Push/Pull
alias pullme='git pull origin main'
alias pushme='git push origin HEAD'
alias pushmef='git push --force-with-lease origin HEAD'

# Git Status
alias st='git status --short'

# Git Rebase
alias re='git rebase'
alias res='GIT_EDITOR=true git rebase --skip'
alias rec='GIT_EDITOR=true git rebase --continue'
alias rea='GIT_EDITOR=true git rebase --abort'
alias reh='git rebase HEAD'
alias rehu='git rebase HEAD --update-refs'
alias rem='git rebase main'
alias remu='git rebase main --update-refs'

# Other Git Commands
alias chp='git cherry-pick'
alias gg='git grep'
alias bl='git blame -w'

# Graphite Commands
alias gts='gt sync --force'

# Claude Code Commands
alias claude!='claude --dangerously-skip-permissions'

# macOS-specific: Homebrew paths
if [[ "$OSTYPE" == darwin* ]]; then
  export PATH=${PATH}:/opt/homebrew/bin:/opt/homebrew/sbin
fi

# .local bin
export PATH=${PATH}:$HOME/.local/bin

export OP_BIOMETRIC_UNLOCK_ENABLED=true

# Lazy-load Graphite CLI completion (saves ~100ms on startup)
if command -v gt > /dev/null; then
  gt() {
    unfunction gt
    eval "$(command gt completion)"
    command gt "$@"
  }
fi

# macOS-specific: LM Studio CLI
if [[ "$OSTYPE" == darwin* ]]; then
  # Added by LM Studio CLI (lms)
  export PATH="$PATH:$HOME/.lmstudio/bin"
  # End of LM Studio CLI section
fi

