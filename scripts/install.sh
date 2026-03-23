#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$ROOT/packages/Brewfile"

log() {
  printf '%s\n' "$*"
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
