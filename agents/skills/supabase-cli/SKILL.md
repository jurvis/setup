---
name: supabase-cli
description: Interact with Supabase through the official CLI: install/check the CLI, initialize or link projects, run the local stack, manage migrations and schema diffs, push or pull database changes, generate types, manage Edge Functions and secrets, and troubleshoot CLI auth or linking issues. Use when the user mentions Supabase CLI commands, a `supabase/` directory, project refs, migrations, `db push`/`db pull`, `functions deploy`, or local Supabase services.
---

# Supabase CLI

Prefer official CLI paths, local-first workflow, exact command output.

## Start Here

- Prefer repo-local CLI in JS/TS repos:
  - `npx supabase --version`
  - fallback: `supabase --version`
- Check repo state before acting:
  - `ls supabase`
  - `test -f supabase/config.toml`
  - `find supabase/migrations -maxdepth 1 -type f | sort`
- If command surface may vary by installed version, verify:
  - `npx supabase --help`
  - `npx supabase <group> --help`
- If local stack needed, confirm Docker-compatible runtime exists.
- Keep secrets out of shell history when possible. Prefer env vars:
  - `SUPABASE_ACCESS_TOKEN`
  - `SUPABASE_DB_PASSWORD`

## Workflow Map

- Local setup, login, linking, environment checks:
  - Read [setup-and-auth.md](./references/setup-and-auth.md)
- Migrations, diffs, resets, pushes, dumps, generated types:
  - Read [database-workflows.md](./references/database-workflows.md)
- Edge Functions, local function serving, remote secrets:
  - Read [functions-and-secrets.md](./references/functions-and-secrets.md)

## Operating Rules

- Prefer local validation before remote changes:
  - local schema change -> `db reset` / `db lint`
  - function change -> `functions serve`
- Before remote ops, identify exact target:
  - `supabase projects list`
  - confirm `project-ref`
  - confirm linked state
- Before `db push`, inspect pending migrations; use dry run/help if available on installed CLI.
- Before destructive local ops (`db reset`, `stop --no-backup`), warn about data loss; back up if needed.
- For existing hosted projects, pull remote schema before creating new local migrations.
- After schema changes, refresh checked-in generated types if repo uses them.
- Quote exact CLI errors when debugging.

## Defaults

- Use `npx supabase ...` in Node repos unless the repo already standardizes on global `supabase`.
- Use `supabase init` + `supabase start` for new local environments.
- Use `supabase login` + `supabase link --project-ref ...` before hosted-project operations that need linking.
- Use migrations as source of truth; avoid dashboard-only schema edits unless intentionally pulling them back into code.
- Use `--no-verify-jwt` only for intentionally public/webhook Edge Functions.

## Output

- Report:
  - command path used (`npx supabase` vs global)
  - linked project/environment
  - files touched under `supabase/`
  - exact verification run
  - exact error text if blocked
