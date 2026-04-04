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

write_string() {
  local domain="$1"
  local key="$2"
  local value="$3"
  run defaults write "$domain" "$key" -string "$value"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  log "This script only supports macOS."
  exit 1
fi

log "Applying keyboard defaults"
write_bool -g NSAutomaticSpellingCorrectionEnabled false
write_bool -g ApplePressAndHoldEnabled false
write_int -g KeyRepeat 2
write_int -g InitialKeyRepeat 10

log "Disabling Spotlight shortcut so Alfred can use it"
# 64 = Show Spotlight search
run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

log "Applying Dock defaults"
run defaults write com.apple.dock persistent-apps -array
run defaults write com.apple.dock persistent-others -array
write_bool com.apple.dock show-recents false
run defaults write com.apple.dock orientation -string left
write_bool com.apple.dock autohide true
write_float com.apple.dock autohide-delay 0
write_float com.apple.dock autohide-time-modifier 0.15

log "Applying screenshot defaults"
write_string com.apple.screencapture target clipboard

if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY: killall Dock"
elif pgrep -x Dock >/dev/null 2>&1; then
  killall Dock
fi

if [[ "$DRY_RUN" == "1" ]]; then
  log "DRY: killall SystemUIServer"
elif pgrep -x SystemUIServer >/dev/null 2>&1; then
  killall SystemUIServer
fi

log "Done. Some keyboard settings may require logging out and back in."
