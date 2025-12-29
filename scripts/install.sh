#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$ROOT/packages/Brewfile"

if ! command -v brew >/dev/null 2>&1; then
  echo "brew not found. Install Homebrew first."
  exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
  echo "Missing Brewfile: $BREWFILE"
  exit 1
fi

brew bundle --file "$BREWFILE"
