# Functions and secrets

## Local Edge Function workflow

Create function:
- `npx supabase functions new hello-world`

Serve one function locally:
- `npx supabase functions serve hello-world`

Serve without JWT verification:
- `npx supabase functions serve hello-world --no-verify-jwt`

Use `--no-verify-jwt` only for public endpoints or webhooks.

## Deploy

Deploy all local functions:
- `npx supabase functions deploy`

Deploy one function:
- `npx supabase functions deploy hello-world`

List remote functions:
- `npx supabase functions list`

Normal sequence
- `login`
- `projects list`
- `link --project-ref ...`
- `functions serve`
- `functions deploy`

## Secrets

Local function env:
- `supabase/functions/.env`
- loaded during local function development with the local stack

Remote secrets:
- `npx supabase secrets set KEY=value`
- `npx supabase secrets list`
- `npx supabase secrets unset KEY`

Rules
- Never echo real secret values back to the user.
- Prefer env vars or prompted input over hardcoding secrets in committed files.
- If a deploy depends on secrets, set them before `functions deploy`.
