# Minimal environment for all zsh invocations.
export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi
