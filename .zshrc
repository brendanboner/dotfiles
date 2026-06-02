# ~/.zshrc — macOS dev setup (brew + pyenv + tmux)

#### 0) Fast exit for non-interactive shells
[[ -o interactive ]] || return

#### 1) History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

#### 2) Keybindings / editing
bindkey -e
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT

#### 3) Homebrew (Intel + Apple Silicon)
# Prefer brew’s shellenv if available.
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null || brew shellenv)"
fi

#### 4) PATH (clean + predictable)
# zsh prefers arrays; this avoids duplicated PATH entries.
typeset -U path PATH
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "/usr/local/sbin"
  $path
)
export PATH

#### 5) Locale (avoid weird Python / tooling issues)
export LANG="en_IE.UTF-8"
export LC_ALL="en_IE.UTF-8"

#### 6) Less / man paging
export LESS="-R -F -X"
export PAGER="less"

#### 7) Useful defaults
#export EDITOR="nvim"
#export VISUAL="nvim"

#### 8) pyenv (Python)
# Requires: brew install pyenv
export PYENV_ROOT="$HOME/.pyenv"
path=("$PYENV_ROOT/bin" $path)

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
  # Optional: if you use pyenv-virtualenv
  # eval "$(pyenv virtualenv-init - zsh)"
fi

# Optional: faster Python package installs; safe default
export PIP_DISABLE_PIP_VERSION_CHECK=1

#### 9) Tmux helpers + auto-attach
# Start/attach to a default tmux session when opening Terminal (not inside VSCode, not already in tmux, not over ssh unless you want it)
export TMUX_DEFAULT_SESSION="dev"

tm() {
  local s="${1:-$TMUX_DEFAULT_SESSION}"
  command -v tmux >/dev/null 2>&1 || { echo "tmux not installed"; return 1; }
  tmux attach -t "$s" 2>/dev/null || tmux new -s "$s"
}

# Auto-attach on interactive shells (tweak conditions to taste)
if command -v tmux >/dev/null 2>&1; then
  if [[ -z "$TMUX" && -z "$VSCODE_GIT_IPC_HANDLE" ]]; then
    # Avoid auto-tmux in dumb terminals and some automation contexts
    if [[ "$TERM" != "dumb" ]]; then
      # If you *don’t* want auto-attach over SSH, uncomment next line:
      # [[ -n "$SSH_TTY" ]] || tm
      tm
    fi
  fi
fi

#### 10) Completion
autoload -Uz compinit
# Use a cache file to speed this up
compinit -d "$HOME/.zcompdump"

#### 11) Prompt (simple + git branch if available)
autoload -Uz colors && colors
setopt PROMPT_SUBST

git_branch() {
  command -v git >/dev/null 2>&1 || return 0
  local b
  b="$(git symbolic-ref --short HEAD 2>/dev/null)" || return 0
  echo " (%{$fg[magenta]%}$b%{$reset_color%})"
}

PROMPT='%{$fg[cyan]%}%n@%m%{$reset_color%}:%{$fg[yellow]%}%~%{$reset_color%}$(git_branch)
%{$fg[green]%}$ %{$reset_color%}'

#### 12) Aliases (sane defaults)
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -lh'
alias ..='cd ..'
alias ...='cd ../..'

alias g='git'
alias gs='git status'
alias gl='git log --oneline --decorate -n 20'
alias gp='git pull --rebase'
alias gd='git diff'
alias gc='git commit'
alias gca='git commit --amend'

alias v='nvim'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tls='tmux ls'

#### 13) Quality of life functions
mkcd() { mkdir -p "$1" && cd "$1"; }

# Quick: open current dir in Finder
cdf() { open .; }

#### 14) Optional: load machine-local overrides (not committed to git)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
