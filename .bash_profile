# Only run on macOS

if [[ "$OSTYPE" == "darwin"* ]]; then
	# needed for brew
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -r ~/.bashrc ]; then
	source ~/.bashrc
fi

if [ -r ~/.bash_aliases ]; then
	source ~/.bash_aliases
fi


export XDG_CONFIG_HOME="$HOME"/.config
export BASH_SILENCE_DEPRECATION_WARNING=1

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/bbonner/.lmstudio/bin"
# End of LM Studio CLI section

