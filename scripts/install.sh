#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$ROOT/packages/Brewfile"

log() {
  printf '%s\n' "$*"
}

enable_obsidian_cli() {
  local config_dir="$HOME/Library/Application Support/obsidian"
  local config_file="$config_dir/obsidian.json"

  if [[ ! -d "/Applications/Obsidian.app" ]]; then
    log "Obsidian app missing; skip CLI activation"
    return 0
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log "python3 missing; skip Obsidian CLI activation"
    return 0
  fi

  log "Ensuring Obsidian CLI enabled"
  mkdir -p "$config_dir"

  if ! python3 - "$config_file" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
if path.exists():
    raw = path.read_text()
    if raw.strip():
        data = json.loads(raw)
        if not isinstance(data, dict):
            raise SystemExit("obsidian.json root must be an object")
    else:
        data = {}
else:
    data = {}

data["cli"] = True
path.write_text(json.dumps(data, separators=(",", ":")))
PY
  then
    log "Obsidian CLI activation skipped; invalid obsidian.json"
    return 0
  fi

  log "Obsidian CLI flag enabled"
}

install_nix() {
  if command -v nix >/dev/null 2>&1; then
    log "nix already installed"
    return 0
  fi

  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "nix install step only supports macOS"
    exit 1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    log "curl not found. Install curl first."
    exit 1
  fi

  log "Installing nix (multi-user)"
  curl -L https://nixos.org/nix/install | sh -s -- --daemon
}

install_nix

if ! command -v brew >/dev/null 2>&1; then
  log "brew not found. Install Homebrew first."
  exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
  log "Missing Brewfile: $BREWFILE"
  exit 1
fi

log "Installing Homebrew bundle"
brew bundle --file "$BREWFILE"
enable_obsidian_cli
