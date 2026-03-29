# Obsidian Setup

Read when: bootstrapping macOS + Obsidian.

- `packages/Brewfile` installs `obsidian`.
- `config/zsh/.zprofile` keeps `/Applications/Obsidian.app/Contents/MacOS` on `PATH`.
- `scripts/install.sh` sets `"cli": true` in `~/Library/Application Support/obsidian/obsidian.json`.
- `scripts/apply.sh` links tracked vault prefs into `$HOME/Documents/Jurvis' Musings/.obsidian/`.

Tracked vault prefs

- `app.json`
- `appearance.json`
- `community-plugins.json`
- `core-plugins.json`
- `daily-notes.json`
- `graph.json`
- `hotkeys.json`
- `publish.json`
- `templates.json`
- `types.json`
- `.obsidian/plugins/dataview/`
- `.obsidian/themes/Minimal/`

Refresh tracked files from live vault

- `bash scripts/sync-obsidian-config.sh`
- override vault path with `OBSIDIAN_VAULT_DIR=...`
- override repo target with `REPO_OBSIDIAN_DIR=...`
- preview with `DRY_RUN=1`

Skipped on purpose

- `workspace.json`: pane/layout state; noisy
- `core-plugins-migration.json`: migration artifact
- `text-generator.json`: plugin package cache/stale local state
- `~/Library/Application Support/obsidian/*.json` window geometry files: machine-specific
- Chromium cache/db files under app support

Notes

- Official Obsidian CLI still needs an Obsidian build with CLI support.
- First app launch may still show the registration prompt inside Obsidian.
- Current tracked prefs also ship the local `Minimal` theme and `dataview` plugin files.
- Verify with `obsidian help` after opening/restarting Obsidian.
