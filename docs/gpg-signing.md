# GPG / Git Commit Signing Setup

This is the step-by-step checklist for moving Git commit signing from an old Mac to a new Mac using this repo.

## Target Stack

- Homebrew `gnupg`
- Homebrew `pinentry-mac`
- Git commit signing with the existing key
- tracked config in this repo
- manual transfer for secret key material

## Files In This Repo

- `packages/Brewfile`: installs `git`, `gnupg`, and `pinentry-mac`
- `scripts/install.sh`: installs Nix if needed, then runs `brew bundle`
- `scripts/apply.sh`: links tracked config into place
- `config/git/config`: Git identity and commit-signing defaults
- `config/gnupg/gpg-agent.conf`: canonical `gpg-agent` config for future machines

## Old Mac: Export What Matters

1. Create a temporary export folder.

```bash
mkdir -m 700 -p ~/Desktop/gpg-move
```

2. Confirm the signing key exists.

```bash
gpg --list-secret-keys --keyid-format LONG 2C8D6A3A1357AFBACBFF04EB56B2496A5C42A5E0
```

3. Export the secret key and subkeys.

```bash
gpg --armor --export-secret-keys 2C8D6A3A1357AFBACBFF04EB56B2496A5C42A5E0 > ~/Desktop/gpg-move/secret-key.asc
```

4. Export the public key.

```bash
gpg --armor --export 2C8D6A3A1357AFBACBFF04EB56B2496A5C42A5E0 > ~/Desktop/gpg-move/public-key.asc
```

5. Export ownertrust.

```bash
gpg --export-ownertrust > ~/Desktop/gpg-move/ownertrust.txt
```

6. Copy the revocation certificate.

```bash
cp ~/.gnupg/openpgp-revocs.d/* ~/Desktop/gpg-move/
```

7. If GPG is also used as the SSH agent, copy `sshcontrol`.

```bash
[ -f ~/.gnupg/sshcontrol ] && cp ~/.gnupg/sshcontrol ~/Desktop/gpg-move/
```

8. Verify the export bundle contents.

```bash
ls -la ~/Desktop/gpg-move
```

9. Encrypt the bundle before moving it.

```bash
cd ~/Desktop
tar -czf gpg-move.tar.gz gpg-move
gpg -c gpg-move.tar.gz
```

10. Transfer only `~/Desktop/gpg-move.tar.gz.gpg` to the new Mac.

## New Mac: Install And Restore

1. Install Homebrew.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Clone this repo.

```bash
mkdir -p ~/Projects
cd ~/Projects
git clone <your-setup-repo-url> setup
cd setup
```

3. Install Nix.

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

4. Install packages from this repo.

```bash
bash scripts/install.sh
```

5. Link the tracked config from this repo.

```bash
bash scripts/apply.sh
```

This includes the canonical [`gpg-agent.conf`](../config/gnupg/gpg-agent.conf).

6. Move the encrypted export bundle from the old Mac onto the new Mac, for example into `~/Downloads`.

7. Decrypt and unpack it.

```bash
cd ~/Downloads
gpg -d gpg-move.tar.gz.gpg > gpg-move.tar.gz
tar -xzf gpg-move.tar.gz
```

8. Import the public key.

```bash
gpg --import ~/Downloads/gpg-move/public-key.asc
```

9. Import the secret key.

```bash
gpg --import ~/Downloads/gpg-move/secret-key.asc
```

10. Import ownertrust.

```bash
gpg --import-ownertrust ~/Downloads/gpg-move/ownertrust.txt
```

11. If GPG is used for SSH too, restore `sshcontrol`.

```bash
[ -f ~/Downloads/gpg-move/sshcontrol ] && cp ~/Downloads/gpg-move/sshcontrol ~/.gnupg/sshcontrol
chmod 600 ~/.gnupg/sshcontrol 2>/dev/null || true
```

12. Restart `gpg-agent`.

```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

13. Open a fresh terminal window.

14. Confirm the secret key exists.

```bash
gpg --list-secret-keys --keyid-format LONG
```

15. Test raw GPG signing.

```bash
echo "test" | gpg --clearsign
```

16. Test a signed Git commit in a throwaway repo.

```bash
mkdir -p ~/tmp/git-signing-test
cd ~/tmp/git-signing-test
git init
echo hi > test.txt
git add test.txt
git commit -m "test signed commit"
git log --show-signature -1
```

## Canonical `gpg-agent.conf`

Path in this repo:

- [`config/gnupg/gpg-agent.conf`](../config/gnupg/gpg-agent.conf)

Contents:

```conf
pinentry-program /opt/homebrew/bin/pinentry-mac
default-cache-ttl 600
max-cache-ttl 7200
```

## If `pinentry-mac` Does Not Show Up

1. Confirm it is installed.

```bash
which pinentry-mac
ls -l /opt/homebrew/bin/pinentry-mac
```

2. Confirm the agent config points at the Homebrew binary.

```bash
cat ~/.gnupg/gpg-agent.conf
```

3. Make sure the shell exports `GPG_TTY`.

```bash
echo $GPG_TTY
```

If empty, add this to the shell config and open a fresh terminal:

```bash
export GPG_TTY=$(tty)
```

4. Restart the agent.

```bash
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

5. Test `pinentry-mac` directly.

```bash
/opt/homebrew/bin/pinentry-mac
```

Then type:

```text
GETPIN
```

6. Test GPG signing again.

```bash
echo "test" | gpg --clearsign
```

7. If it still fails, confirm Homebrew tools are being used.

```bash
which gpg
which gpgconf
which pinentry-mac
gpgconf --list-dirs
```

## Do Not Transfer Blindly

Do not copy these directly from the old Mac:

- the entire `~/.gnupg` directory
- `S.gpg-agent*` sockets
- `gpg-agent.env`
- lock files
- raw `pubring.kbx` / `trustdb.gpg` database files

Transfer exported keys and trust data instead.
