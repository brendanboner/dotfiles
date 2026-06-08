#!/usr/bin/env bash
# Stage-2 install — runs from ~/dotfiles after bootstrap.sh.
# Idempotent: safe to rerun.

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# Load brew shellenv in case we're invoked from a non-login shell
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 1) Brew bundle
say "Installing packages from Brewfile"
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 2) Symlinks
# link <repo-path> <home-path>
link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    # Existing symlink — replace unconditionally
    ln -sfn "$src" "$dest"
    return
  fi
  if [ -e "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    echo "  backed up $dest -> $BACKUP_DIR/"
  fi
  ln -s "$src" "$dest"
  echo "  $dest -> $src"
}

say "Creating symlinks"
link "$DOTFILES_DIR/home/.zshrc"        "$HOME/.zshrc"
link "$DOTFILES_DIR/home/.zprofile"     "$HOME/.zprofile"
link "$DOTFILES_DIR/home/.aliases"      "$HOME/.aliases"
link "$DOTFILES_DIR/home/.tmux.conf"    "$HOME/.tmux.conf"
link "$DOTFILES_DIR/home/.tmux/nord.conf" "$HOME/.tmux/nord.conf"
link "$DOTFILES_DIR/home/.gitconfig"    "$HOME/.gitconfig"
link "$DOTFILES_DIR/nvim"               "$HOME/.config/nvim"
link "$DOTFILES_DIR/starship.toml"      "$HOME/.config/starship.toml"

# 3) tmux plugin manager
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  say "Installing tpm (tmux plugin manager)"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
# nord.conf currently doesn't use TPM plugins, but install anyway so the
# infra is ready if .tmux.conf grows `set -g @plugin '...'` lines later.
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  "$TPM_DIR/bin/install_plugins" || true
fi

# 4) iTerm2 — load prefs from the repo folder
if [ -d "/Applications/iTerm.app" ] || command -v iterm2 >/dev/null 2>&1; then
  say "Pointing iTerm2 at $DOTFILES_DIR/iterm2"
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
fi

# 5) Done
cat <<EOF

\033[1;32m✔ Setup complete.\033[0m

Next steps:
  1. Restart iTerm2 so it picks up custom-folder prefs.
  2. Launch nvim once — lazy.nvim will auto-install plugins.
  3. Inside tmux, prefix + I installs any plugins (only needed if you add
     '@plugin' lines to .tmux.conf later).
  4. \`exec zsh\` (or open a new terminal) to load the symlinked .zshrc.

Backed-up originals (if any): $BACKUP_DIR
EOF
