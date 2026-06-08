# Dotfiles bootstrap — design

Goal: clone this private repo on a fresh macOS machine and run one script
to end up with the same iTerm2, tmux, neovim, shell config, and brew packages
as my primary machine. No keys are transferred — a fresh SSH key is generated
on the new machine.

## Two-stage flow

**Stage 1 — `bootstrap.sh`** (typed/pasted on the new machine; repo is private
so it can't be curl'd):

1. Trigger `xcode-select --install` and wait for the GUI installer.
2. Install Homebrew if missing; load `brew shellenv` for the current shell.
3. `brew install gh git`.
4. If `~/.ssh/id_ed25519` does not exist, generate one (no passphrase prompt
   suppression — user chooses), `pbcopy` the public key, open
   `https://github.com/settings/ssh/new`, and wait for the user to confirm.
5. Verify with `ssh -T git@github.com` (accept the host key on first run).
6. `git clone git@github.com:brendanboner/dotfiles.git ~/dotfiles`.
7. `exec ~/dotfiles/install.sh`.

**Stage 2 — `install.sh`** (lives in the repo, idempotent):

1. `brew bundle --file=~/dotfiles/Brewfile`.
2. Symlink home files (see table below). Existing real files at the target
   are moved to `~/.dotfiles-backup-<timestamp>/` first.
3. Clone tpm if absent, `tmux source-file ~/.tmux.conf` if a server is
   running, run `~/.tmux/plugins/tpm/bin/install_plugins`.
4. Set iTerm2 to read prefs from the repo:
   `defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/dotfiles/iterm2"`
   and `LoadPrefsFromCustomFolder -bool true`.
5. Print a short "next steps" summary (start nvim once for lazy.nvim to
   hydrate; restart iTerm to pick up prefs).

## Symlinks

| Link                          | Target                                  |
|-------------------------------|-----------------------------------------|
| `~/.zshrc`                    | `~/dotfiles/home/.zshrc`                |
| `~/.zprofile`                 | `~/dotfiles/home/.zprofile`             |
| `~/.aliases`                  | `~/dotfiles/home/.aliases`              |
| `~/.tmux.conf`                | `~/dotfiles/home/.tmux.conf`            |
| `~/.gitconfig`                | `~/dotfiles/home/.gitconfig`            |
| `~/.config/nvim`              | `~/dotfiles/nvim`                       |
| `~/.config/starship.toml`     | `~/dotfiles/starship.toml`              |

iTerm2 prefs are not symlinked — `defaults write` makes iTerm load from
`~/dotfiles/iterm2/` directly. This way iTerm's own preference writes flow
back into the repo and can be committed.

## Repo layout after this work

```
~/dotfiles/
  bootstrap.sh           # stage 1
  install.sh             # stage 2
  Brewfile               # brew bundle dump
  README.md              # user-facing setup steps
  docs/
    setup-design.md      # this file
  home/                  # files that symlink into $HOME
    .zshrc
    .zprofile
    .aliases
    .tmux.conf
    .gitconfig
  iterm2/
    com.googlecode.iterm2.plist
  nvim/                  # existing — symlinked from ~/.config/nvim
  starship.toml          # existing — symlinked from ~/.config/starship.toml
```

Legacy files removed from the repo: `.bashrc`, `.bash_profile`,
`.bash_aliases`, `.fsf.bash`, `.fzf.bash`, `.tmux.conf.bb`, `vim/`,
`scripts/`, the old `setup`, `Nord.itermcolors` (replaced by full plist).

## What this explicitly does not handle

- SSH/GPG keys — generated fresh on the new machine.
- AWS configs, cloud creds, app login state.
- macOS system preferences (Dock, keyboard, trackpad, etc.).
- OneDrive / iCloud / Library content.
- Anything outside the dotfiles domain.

## Safety properties

- `install.sh` is idempotent — rerunning links over existing symlinks via
  `ln -sfn`, only backs up *real* files (not existing correct symlinks).
- The script never deletes anything; replaced files go to a timestamped
  backup directory.
- Bootstrap stops before clone if `ssh -T git@github.com` fails, so a
  half-configured machine doesn't proceed.
