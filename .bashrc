#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# PS1='[\u@\h \W]\$ '

# Set to superior editing mode
set -o vi

# keybinds
bind -x '"\C-l":clear'
# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

export VISUAL=nvim
export EDITOR=nvim

# config
export BROWSER="firefox"

# directories
export REPOS="$HOME/Repos"
export GITUSER="brendanboner"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dotfiles"
export LAB="$GHREPOS/lab"
export SCRIPTS="$DOTFILES/scripts"
export ICLOUD="$HOME/icloud"

# https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path
# PATH="${PATH:+${PATH}:}~/opt/bin"   # appending
# PATH="~/opt/bin${PATH:+:${PATH}}"   # prepending

# Commands also provided by macOS and the commands dir, dircolors, vdir have been installed with the prefix "g".
# If you need to use these commands with their normal names, you can add a "gnubin" directory to your PATH with:
#  PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"

# ~~~~~~~~~~~~~~~ History ~~~~~~~~~~~~~~~~~~~~~~~~

export HISTFILE=~/.histfile
export HISTSIZE=25000
export SAVEHIST=25000
export HISTCONTROL=ignorespace

# ~~~~~~~~~~~~~~~ Functions ~~~~~~~~~~~~~~~~~~~~~~~~

# This function is stolen from rwxrob

clone() {
	local repo="$1" user
	local repo="${repo#https://github.com/}"
	local repo="${repo#git@github.com:}"
	if [[ $repo =~ / ]]; then
		user="${repo%%/*}"
	else
		user="$GITUSER"
		[[ -z "$user" ]] && user="$USER"
	fi
	local name="${repo##*/}"
	local userd="$REPOS/github.com/$user"
	local path="$userd/$name"
	[[ -d "$path" ]] && cd "$path" && return
	mkdir -p "$userd"
	cd "$userd"
	echo gh repo clone "$user/$name" -- --recurse-submodule
	gh repo clone "$user/$name" -- --recurse-submodule
	cd "$name"
} && export -f clone

# ~~~~~~~~~~~~~~~ SSH ~~~~~~~~~~~~~~~~~~~~~~~~
# SSH Script from arch wiki

# adding keys was buggy, add them outside of the script for now
# ssh-add -q ~/.ssh/mischa
# ssh-add -q ~/.ssh/mburg
#{
#ssh-add -q ~/.ssh/bbonner
#ssh-add -q ~/.ssh/brendanboner
#} &>/dev/null

# ~~~~~~~~~~~~~~~ Prompt ~~~~~~~~~~~~~~~~~~~~~~~~

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
# Explicitly unset color (default anyhow). Use 1 to set it.
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"
# export GIT_PS1_SHOWUPSTREAM="auto git"

# if [[ -f "$XDG_CONFIG_HOME/bash/gitprompt.sh" ]]; then
# 	source "$XDG_CONFIG_HOME/bash/gitprompt.sh"
# fi

# PROMPT_COMMAND='__git_ps1 "\u@\h:\W" " \n$ "'
# colorized prompt
function parse_git_dirty {
	[[ $(git status --porcelain 2>/dev/null) ]] && echo "*"
}
function parse_git_branch {
	git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"
}

export PS1="\n\t \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
#PROMPT_COMMAND="\n\t \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# The __git_ps1 function prompt is provided by the bash completion installed by brew. See https://github.com/mischavandenburg/dotfiles/issues/5

# ~~~~~~~~~~~~~~~ Aliases ~~~~~~~~~~~~~~~~~~~~~~~~

alias v=nvim
alias vi=nvim
# alias vim=nvim

# cd
alias vo='cd $REPOS/github.com/VanOord/'
alias ..="cd .."
alias scripts='cd $SCRIPTS'
alias cdblog="cd ~/websites/blog"
alias cdpblog='cd $SECOND_BRAIN/2-areas/blog/content'
alias lab='cd $LAB'
alias alab='cd $GHREPOS/azure-lab'
alias dot='cd $GHREPOS/dotfiles'
alias repos='cd $REPOS'
alias cdgo='cd $GHREPOS/go/'
alias ex='cd $REPOS/github.com/mischavandenburg/go/Exercism/'
alias rwdot='cd $REPOS/github.com/rwxrob/dot'
alias c="clear"
alias icloud="cd \$ICLOUD"
alias rob='cd $REPOS/github.com/rwxrob'
alias homelab='cd $REPOS/github.com/mischavandenburg/homelab/'
alias hl='homelab'
alias hlp='cd $REPOS/github.com/mischavandenburg/homelab-private/'
alias hlps='cd $REPOS/github.com/mischavandenburg/homelab-private-staging/'
alias hlpp='cd $REPOS/github.com/mischavandenburg/homelab-private-production/'

# ls
alias ls='ls --color=auto'
alias ll='ls -la'
# alias la='exa -laghm@ --all --icons --git --color=always'
alias la='ls -lathr'

# finds all files recursively and sorts by last modification, ignore hidden files
alias last='find . -type f -not -path "*/\.*" -exec ls -lrt {} +'

alias sv='sudoedit'
alias t='tmux'
alias e='exit'
alias syu='sudo pacman -Syu'

# git
alias gp='git pull'
alias gs='git status'
alias lg='lazygit'

# ricing
alias et='v ~/.config/awesome/themes/powerarrow/theme-personal.lua'
alias ett='v ~/.config/awesome/themes/powerarrow-dark/theme-personal.lua'
alias er='v ~/.config/awesome/rc.lua'
alias eb='v ~/.bashrc'
alias ev='cd ~/.config/nvim/ && v init.lua'
alias sbr='source ~/.bashrc'
alias s='startx'

# vim & second brain
alias sb="cd \$SECOND_BRAIN"
alias in="cd \$SECOND_BRAIN/0 Inbox/"
alias vbn='python ~/git/python/brainfile.py'

# starting programmes
alias cards='python3 /opt/homebrew/lib/python3.11/site-packages/mtg_proxy_printer/'

# terraform
alias tf='terraform'
alias tp='terraform plan'

# fun
alias fishies=asciiquarium

# kubectl
alias k='kubectl'
source <(kubectl completion bash)
complete -o default -F __start_kubectl k
alias kgp='kubectl get pods'
alias kc='kubectx'
alias kn='kubens'

alias kcs='kubectl config use-context admin@homelab-staging'
alias kcp='kubectl config use-context admin@homelab-production'

# fzf aliases
# use fp to do a fzf search and preview the files
alias fp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'"
# search for a file with fzf and open it in vim
alias vf='v $(fp)'

# sourcing

if [[ "$OSTYPE" == "darwin"* ]]; then
	# echo "I'm on Mac!"

	# brew bash completion
	[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"
else
	#	source /usr/share/fzf/key-bindings.bash
	#	source /usr/share/fzf/completion.bash
	[ -f ~/.fzf.bash ] && source ~/.fzf.bash
fi

alias dev='ssh brendan@dev.lan'
alias pve='ssh root@pve.lan'
alias bev='ssh brendan@192.168.13.20'
alias bev2='ssh brendan@192.168.13.100 -p 2222'
