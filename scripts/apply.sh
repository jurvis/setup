#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${DRY_RUN:-0}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)}"
DEFAULT_OBSIDIAN_VAULT_DIR="$HOME/Documents/Jurvis"$'\' Musings'
OBSIDIAN_VAULT_DIR="${OBSIDIAN_VAULT_DIR:-$DEFAULT_OBSIDIAN_VAULT_DIR}"

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

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY LINK: $dest -> $src"
  else
    log "LINK: $dest -> $src"
  fi
}

# XDG config dirs
link_path "$ROOT/config/zsh" "$HOME/.config/zsh"
link_path "$ROOT/config/tmux" "$HOME/.config/tmux"
link_path "$ROOT/config/nvim" "$HOME/.config/nvim"
link_path "$ROOT/config/ghostty" "$HOME/.config/ghostty"
link_path "$ROOT/config/alacritty" "$HOME/.config/alacritty"
link_path "$ROOT/config/git" "$HOME/.config/git"
link_path "$ROOT/config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
link_path "$ROOT/config/nix" "$HOME/.config/nix"
link_path "$ROOT/config/vim" "$HOME/.config/vim"
link_path "$ROOT/config/zellij" "$HOME/.config/zellij"
link_path "$ROOT/config/gnupg/gpg-agent.conf" "$HOME/.gnupg/gpg-agent.conf"

# Traditional dotfiles (symlink into XDG)
link_path "$ROOT/config/zsh/.zshrc" "$HOME/.zshrc"
link_path "$ROOT/config/zsh/.zshenv" "$HOME/.zshenv"
link_path "$ROOT/config/zsh/.zprofile" "$HOME/.zprofile"
link_path "$ROOT/config/tmux/tmux.conf" "$HOME/.tmux.conf"
link_path "$ROOT/config/git/config" "$HOME/.gitconfig"
link_path "$ROOT/config/vim/vimrc" "$HOME/.vimrc"

# Obsidian vault config
link_path "$ROOT/config/obsidian/vault/.obsidian/app.json" "$OBSIDIAN_VAULT_DIR/.obsidian/app.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/appearance.json" "$OBSIDIAN_VAULT_DIR/.obsidian/appearance.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/community-plugins.json" "$OBSIDIAN_VAULT_DIR/.obsidian/community-plugins.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/core-plugins.json" "$OBSIDIAN_VAULT_DIR/.obsidian/core-plugins.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/daily-notes.json" "$OBSIDIAN_VAULT_DIR/.obsidian/daily-notes.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/graph.json" "$OBSIDIAN_VAULT_DIR/.obsidian/graph.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/hotkeys.json" "$OBSIDIAN_VAULT_DIR/.obsidian/hotkeys.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/publish.json" "$OBSIDIAN_VAULT_DIR/.obsidian/publish.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/templates.json" "$OBSIDIAN_VAULT_DIR/.obsidian/templates.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/types.json" "$OBSIDIAN_VAULT_DIR/.obsidian/types.json"
link_path "$ROOT/config/obsidian/vault/.obsidian/plugins/dataview" "$OBSIDIAN_VAULT_DIR/.obsidian/plugins/dataview"
link_path "$ROOT/config/obsidian/vault/.obsidian/themes/Minimal" "$OBSIDIAN_VAULT_DIR/.obsidian/themes/Minimal"
