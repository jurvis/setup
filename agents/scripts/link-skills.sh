#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
CODEX_SKILLS="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Missing skills dir: $SKILLS_DIR" >&2
  exit 1
fi

if [ ! -d "$CODEX_SKILLS" ]; then
  echo "Missing Codex skills dir: $CODEX_SKILLS" >&2
  exit 1
fi

shopt -s nullglob

linked=0
skipped=0

for skill_path in "$SKILLS_DIR"/*; do
  name="$(basename "$skill_path")"

  if [ "$name" = "README.md" ]; then
    continue
  fi

  if [ ! -d "$skill_path" ]; then
    continue
  fi

  target="$CODEX_SKILLS/$name"

  if [ -L "$target" ]; then
    existing="$(readlink "$target")"
    if [ "$existing" = "$skill_path" ]; then
      echo "ok  $name"
      continue
    fi
    echo "skip $name (symlink exists -> $existing)"
    skipped=$((skipped + 1))
    continue
  fi

  if [ -e "$target" ]; then
    echo "skip $name (path exists)"
    skipped=$((skipped + 1))
    continue
  fi

  ln -s "$skill_path" "$target"
  echo "link $name"
  linked=$((linked + 1))
done

echo "done  linked=$linked skipped=$skipped"
