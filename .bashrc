#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# keybinds
bind -x '"\C-l":clear'

# ~~~~~~~~~~~~~~~ Environment Variables ~~~~~~~~~~~~~~~~~~~~~~~~

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

# ~~~~~~~~~~~~~~~ SSH ~~~~~~~~~~~~~~~~~~~~~~~~
# SSH Script from arch wiki

# adding keys was buggy, add them outside of the script for now
# ssh-add -q ~/.ssh/mischa
# ssh-add -q ~/.ssh/mburg

eval "$(zoxide init bash)"
alias cd=z

function parse_git_dirty { [[ $(git status --porcelain 2>/dev/null) ]] && echo "*"; }
function parse_git_branch { git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1$(parse_git_dirty))/"; }
export PS1="[\h]\[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\]\$ "
