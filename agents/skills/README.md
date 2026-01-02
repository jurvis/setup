# Skills (Codex)

This folder is the canonical source for Codex skills on this laptop. Each
skill folder is symlinked into `~/.codex/skills` (which also contains Codex
system skills).

## Layout
- `skills/<skill-name>/SKILL.md` — entry point + instructions.
- Optional: `references/`, `scripts/`, `assets/` inside each skill.

## Add a skill
1. Create `skills/<skill-name>/SKILL.md`.
2. Keep instructions tight; link to local references if needed.
3. Symlink the skill into Codex:
   `ln -sfn ~/Projects/setup/agents/skills/<skill-name> ~/.codex/skills/<skill-name>`
4. Commit here; Codex will pick it up via the symlink.

## Notes
- Prefer repo-backed skills; avoid local-only copies.
- Keep `~/.codex/skills/.system` intact (Codex-managed).
