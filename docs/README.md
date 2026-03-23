# Docs

- `scripts/apply.sh` symlinks managed config into `~/.config`, including Nix config at `~/.config/nix/nix.conf`.
- [`config/karabiner/karabiner.json`](../config/karabiner/karabiner.json) is the canonical Karabiner-Elements config. `scripts/apply.sh` links it to `~/.config/karabiner/karabiner.json`; Karabiner's `automatic_backups/` remains local machine state and is not tracked here.
- [GPG / Git Commit Signing Setup](./gpg-signing.md)
