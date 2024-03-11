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
