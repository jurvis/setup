# Setup and auth

## Install / check

- Prefer repo-local CLI in JS repos:
  - `npx supabase --version`
- Global fallback:
  - `supabase --version`
- If CLI missing and user wants install:
  - `npm install -D supabase`
- Local stack needs Docker-compatible APIs. Official docs call out Docker Desktop and compatible runtimes like Podman, OrbStack, Rancher Desktop, colima.

## New local project

- Init:
  - `npx supabase init`
- Start full stack:
  - `npx supabase start`
- Check service status:
  - `npx supabase status`
- Stop without reset:
  - `npx supabase stop`

Notes
- `supabase init` creates `supabase/`.
- `supabase start` needs `supabase/config.toml`.
- Official docs recommend enough RAM for full stack; if startup fails, inspect container/runtime health first.

## Hosted project auth / link

- Login interactively:
  - `npx supabase login`
- CI / non-interactive:
  - set `SUPABASE_ACCESS_TOKEN`
- List accessible projects:
  - `npx supabase projects list`
- Link repo to hosted project:
  - `npx supabase link --project-ref "$PROJECT_REF"`
- Non-interactive password path:
  - set `SUPABASE_DB_PASSWORD`

Notes
- `login` stores token in native credential storage when possible; fallback may write `~/.supabase/access-token`.
- `link` is prerequisite for commands like `db pull`, `db push`, `db dump`.

## First-pass diagnostics

- Confirm CLI surface:
  - `npx supabase --help`
  - `npx supabase db --help`
  - `npx supabase functions --help`
- Confirm repo state:
  - `test -f supabase/config.toml`
  - `find supabase/migrations -maxdepth 1 -type f | sort`
- Confirm linked ref when needed:
  - inspect `supabase/config.toml`
  - or rerun `npx supabase link --project-ref "$PROJECT_REF"`
