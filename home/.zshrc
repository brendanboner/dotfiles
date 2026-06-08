fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

source ~/.aliases
source ~/.env

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"

setopt interactivecomments
