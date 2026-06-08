fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

source ~/.aliases

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"



# AWS SSO profile — `aws sso login` once per ~8h, then all aws commands work
export AWS_PROFILE=PowerUserAccess-716121312929
setopt interactivecomments
