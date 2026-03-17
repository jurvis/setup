#!/usr/bin/env bash
set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

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

write_bool() {
  local domain="$1"
  local key="$2"
  local value="$3"
  run defaults write "$domain" "$key" -bool "$value"
}

write_int() {
  local domain="$1"
  local key="$2"
  local value="$3"
  run defaults write "$domain" "$key" -int "$value"
}

write_float() {
  local domain="$1"
  local key="$2"
  local value="$3"
  run defaults write "$domain" "$key" -float "$value"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  log "This script only supports macOS."
  exit 1
fi

log "Applying keyboard defaults"
write_bool -g NSAutomaticSpellingCorrectionEnabled false
write_bool -g ApplePressAndHoldEnabled false
write_int -g KeyRepeat 1
write_int -g InitialKeyRepeat 10

log "Applying Dock defaults"
run defaults write com.apple.dock persistent-apps -array
run defaults write com.apple.dock persistent-others -array
write_bool com.apple.dock show-recents false
run defaults write com.apple.dock orientation -string left
write_bool com.apple.dock autohide true
write_float com.apple.dock autohide-delay 0
write_float com.apple.dock autohide-time-modifier 0.15

if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY: killall Dock"
elif pgrep -x Dock >/dev/null 2>&1; then
  killall Dock
fi

log "Done. Some keyboard settings may require logging out and back in."
