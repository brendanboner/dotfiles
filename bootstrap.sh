#!/usr/bin/env bash
# Stage-1 bootstrap for a fresh macOS machine.
#
# Run this manually (paste, AirDrop, or USB). It cannot be curl'd from the
# private dotfiles repo because the repo is private and the machine has no
# auth yet. End state: ~/dotfiles is cloned and ./install.sh has been
# exec'd to finish the setup.

set -euo pipefail

REPO_SSH="git@github.com:brendanboner/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
SSH_KEY="$HOME/.ssh/id_ed25519"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\n\033[1;33m!! %s\033[0m\n' "$*"; }
pause() { read -r -p "$1 (press Enter to continue) " _; }

# 1) Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  say "Installing Xcode Command Line Tools (GUI installer will appear)"
  xcode-select --install || true
  pause "Finish the CLT installer in the GUI, then return here"
fi

# 2) Homebrew
if ! command -v brew >/dev/null 2>&1; then
  say "Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Apple Silicon vs Intel
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3) Minimum tools to clone the repo
say "Installing git and gh"
brew install git gh

# 4) SSH key
if [ ! -f "$SSH_KEY" ]; then
  say "Generating ed25519 SSH key"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname) $(date -u +%Y-%m-%d)" -f "$SSH_KEY"
fi

# 5) GitHub trust + key registration
mkdir -p "$HOME/.ssh"
if ! grep -q "^github.com " "$HOME/.ssh/known_hosts" 2>/dev/null; then
  ssh-keyscan -t ed25519,rsa github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

if ! ssh -T -o BatchMode=yes -o StrictHostKeyChecking=accept-new git@github.com 2>&1 | grep -q "successfully authenticated"; then
  say "Your public key — add it to GitHub now"
  echo
  cat "$SSH_KEY.pub"
  echo
  pbcopy < "$SSH_KEY.pub" 2>/dev/null && echo "(copied to clipboard)"
  open "https://github.com/settings/ssh/new" 2>/dev/null || true
  pause "Add the key on GitHub, then return here"

  if ! ssh -T -o BatchMode=yes -o StrictHostKeyChecking=accept-new git@github.com 2>&1 | grep -q "successfully authenticated"; then
    warn "GitHub SSH auth still failing. Fix and rerun this script."
    exit 1
  fi
fi
say "GitHub SSH auth OK"

# 6) Clone
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  say "Cloning $REPO_SSH -> $DOTFILES_DIR"
  git clone "$REPO_SSH" "$DOTFILES_DIR"
else
  say "Repo already at $DOTFILES_DIR — pulling latest"
  git -C "$DOTFILES_DIR" pull --ff-only
fi

# 7) Hand off to stage 2
say "Handing off to install.sh"
exec "$DOTFILES_DIR/install.sh"
