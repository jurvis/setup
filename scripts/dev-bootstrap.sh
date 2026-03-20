#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
OH_MY_ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"

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

pick_zsh_shell() {
  local candidate

  for candidate in /opt/homebrew/bin/zsh /usr/local/bin/zsh "$(command -v zsh 2>/dev/null || true)" /bin/zsh; do
    [[ -n "$candidate" ]] || continue
    [[ -x "$candidate" ]] || continue

    if grep -Fxq "$candidate" /etc/shells 2>/dev/null; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  log "No usable zsh binary found in /etc/shells."
  exit 1
}

install_or_update_repo() {
  local repo_url="$1"
  local repo_dir="$2"

  if [[ -d "$repo_dir/.git" ]]; then
    run git -C "$repo_dir" fetch --tags --force origin
  elif [[ -e "$repo_dir" ]]; then
    log "Path exists but is not a git repo: $repo_dir"
    exit 1
  else
    run git clone "$repo_url" "$repo_dir"
    run git -C "$repo_dir" fetch --tags --force origin
  fi
}

install_oh_my_zsh() {
  log "Installing oh-my-zsh"
  install_or_update_repo "https://github.com/ohmyzsh/ohmyzsh.git" "$OH_MY_ZSH_DIR"
}

set_default_shell() {
  local shell_path
  shell_path="$(pick_zsh_shell)"

  if [[ "${SHELL:-}" == "$shell_path" ]]; then
    log "Default shell already set to $shell_path"
    return 0
  fi

  log "Setting default shell to $shell_path"
  run chsh -s "$shell_path"
}

install_nvm() {
  local latest_tag

  log "Installing nvm"
  install_or_update_repo "https://github.com/nvm-sh/nvm.git" "$NVM_DIR"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: determine latest nvm tag"
    return 0
  fi

  latest_tag="$(git -C "$NVM_DIR" tag --sort=-v:refname | head -n1)"
  if [[ -z "$latest_tag" ]]; then
    log "Unable to determine latest nvm tag."
    exit 1
  fi

  git -C "$NVM_DIR" checkout --quiet "$latest_tag"
}

load_nvm() {
  if [[ "$DRY_RUN" == "1" ]]; then
    return 0
  fi

  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "Missing nvm loader: $NVM_DIR/nvm.sh"
    exit 1
  fi

  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
}

install_node_and_clis() {
  log "Installing latest Node.js with nvm"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: nvm install node"
    log "DRY: nvm alias default node"
    log "DRY: nvm use default"
    log "DRY: npm install -g @anthropic-ai/claude-code @openai/codex"
    return 0
  fi

  nvm install node
  nvm alias default node
  nvm use default
  npm install -g @anthropic-ai/claude-code @openai/codex
}

install_rust() {
  log "Installing rustup"

  if command -v rustup >/dev/null 2>&1; then
    if [[ "$DRY_RUN" == "1" ]]; then
      log "DRY: rustup update"
    else
      rustup update
    fi
    return 0
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: curl https://sh.rustup.rs | sh -s -- -y"
    return 0
  fi

  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y
}

install_uv() {
  log "Installing uv"

  if command -v uv >/dev/null 2>&1; then
    log "uv already installed"
    return 0
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: curl https://astral.sh/uv/install.sh | sh"
    return 0
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
}

load_rust_env() {
  if [[ "$DRY_RUN" == "1" ]]; then
    return 0
  fi

  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck disable=SC1090
    . "$HOME/.cargo/env"
  fi
}

install_zellij() {
  log "Installing zellij"

  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY: cargo install --locked zellij --force"
    return 0
  fi

  cargo install --locked zellij --force
}

need_cmd git
need_cmd curl
need_cmd chsh

install_oh_my_zsh
set_default_shell
install_nvm
load_nvm
install_node_and_clis
install_rust
load_rust_env
install_uv
need_cmd cargo
install_zellij

log "Done. Restart your shell after the script finishes."
