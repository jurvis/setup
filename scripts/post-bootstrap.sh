#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${DRY_RUN:-0}"
BOOTSTRAP_CONFIG_HOME=""

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

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    exit 1
  fi
}

cleanup() {
  if [[ -n "$BOOTSTRAP_CONFIG_HOME" && -d "$BOOTSTRAP_CONFIG_HOME" ]]; then
    rm -rf "$BOOTSTRAP_CONFIG_HOME"
  fi
}

prepare_nvim_config() {
  if [[ "$DRY_RUN" == "1" ]]; then
    BOOTSTRAP_CONFIG_HOME="${TMPDIR:-/tmp}/setup-nvim-bootstrap.dry-run"
    log "DRY: create temporary XDG config home at $BOOTSTRAP_CONFIG_HOME"
    log "DRY: link $ROOT/config/nvim to $BOOTSTRAP_CONFIG_HOME/nvim"
  else
    BOOTSTRAP_CONFIG_HOME="$(mktemp -d "${TMPDIR:-/tmp}/setup-nvim-bootstrap.XXXXXX")"
    ln -s "$ROOT/config/nvim" "$BOOTSTRAP_CONFIG_HOME/nvim"
  fi

  export XDG_CONFIG_HOME="$BOOTSTRAP_CONFIG_HOME"
}

prepare_runtime_dirs() {
  export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
  export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
  export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

  run mkdir -p "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
}

install_nvim_plugins() {
  log "Installing Neovim plugins with lazy.nvim"
  run nvim --headless "+Lazy! sync" +qa
}

install_mason_tools() {
  log "Installing Mason-managed tools"
  run nvim --headless "+MasonToolsInstallSync" +qa
}

trap cleanup EXIT

need_cmd git
need_cmd nvim

prepare_nvim_config
prepare_runtime_dirs
install_nvim_plugins
install_mason_tools

log "Done."
