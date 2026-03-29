#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_OBSIDIAN_VAULT_DIR="$HOME/Documents/Jurvis"$'\' Musings'
OBSIDIAN_VAULT_DIR="${OBSIDIAN_VAULT_DIR:-$DEFAULT_OBSIDIAN_VAULT_DIR}"
REPO_OBSIDIAN_DIR="${REPO_OBSIDIAN_DIR:-$ROOT/config/obsidian/vault/.obsidian}"
DRY_RUN="${DRY_RUN:-0}"

TRACKED_FILES=(
  app.json
  appearance.json
  community-plugins.json
  core-plugins.json
  daily-notes.json
  graph.json
  hotkeys.json
  publish.json
  templates.json
  types.json
)

TRACKED_DIRS=(
  plugins/dataview
  themes/Minimal
)

log() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: $*"
    return 0
  fi

  "$@"
}

need_path() {
  local path="$1"

  if [[ ! -e "$path" ]]; then
    log "Missing required path: $path"
    exit 1
  fi
}

sync_file() {
  local rel="$1"
  local src="$OBSIDIAN_VAULT_DIR/.obsidian/$rel"
  local dest="$REPO_OBSIDIAN_DIR/$rel"

  need_path "$src"
  run mkdir -p "$(dirname "$dest")"
  run cp "$src" "$dest"
  log "SYNC FILE: $rel"
}

sync_dir() {
  local rel="$1"
  local src="$OBSIDIAN_VAULT_DIR/.obsidian/$rel"
  local dest="$REPO_OBSIDIAN_DIR/$rel"

  need_path "$src"
  run mkdir -p "$dest"
  run rsync -a "$src/" "$dest/"
  log "SYNC DIR: $rel"
}

need_path "$OBSIDIAN_VAULT_DIR/.obsidian"
command -v rsync >/dev/null 2>&1 || {
  log "Missing required command: rsync"
  exit 1
}

for rel in "${TRACKED_FILES[@]}"; do
  sync_file "$rel"
done

for rel in "${TRACKED_DIRS[@]}"; do
  sync_dir "$rel"
done
