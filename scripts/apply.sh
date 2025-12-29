#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${DRY_RUN:-1}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"

log() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: $*"
  else
    "$@"
  fi
}

link_path() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      log "OK: $dest -> $src"
      return 0
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    run mkdir -p "$BACKUP_DIR"
    run mv "$dest" "$BACKUP_DIR/"
  fi

  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  log "LINK: $dest -> $src"
}

# XDG config dirs
link_path "$ROOT/config/zsh" "$HOME/.config/zsh"
link_path "$ROOT/config/tmux" "$HOME/.config/tmux"
link_path "$ROOT/config/nvim" "$HOME/.config/nvim"
link_path "$ROOT/config/ghostty" "$HOME/.config/ghostty"
link_path "$ROOT/config/alacritty" "$HOME/.config/alacritty"
link_path "$ROOT/config/git" "$HOME/.config/git"
link_path "$ROOT/config/vim" "$HOME/.config/vim"

# Traditional dotfiles (symlink into XDG)
link_path "$ROOT/config/zsh/.zshrc" "$HOME/.zshrc"
link_path "$ROOT/config/zsh/.zshenv" "$HOME/.zshenv"
link_path "$ROOT/config/zsh/.zprofile" "$HOME/.zprofile"
link_path "$ROOT/config/tmux/tmux.conf" "$HOME/.tmux.conf"
link_path "$ROOT/config/git/config" "$HOME/.gitconfig"
link_path "$ROOT/config/vim/vimrc" "$HOME/.vimrc"
