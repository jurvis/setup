# Database workflows

## Existing hosted project -> local source of truth

- Login + link first.
- Pull dashboard-made remote schema changes before new local work:
  - `npx supabase db pull`
- Result: new migration under `supabase/migrations/`.

## Create schema changes

Manual migration:
- `npx supabase migration new add_widgets`

Diff from local changes:
- make local changes
- generate migration:
  - `npx supabase db diff -f add_widgets`

Local verification:
- rebuild local DB from migrations:
  - `npx supabase db reset`
- lint SQL / schema:
  - `npx supabase db lint`

## Push to hosted project

- Inspect migration files first.
- Apply pending migrations:
  - `npx supabase db push`
- Check history:
  - `npx supabase migration list`

Use care
- Treat `db push` as environment-specific. Confirm target ref before run.
- If installed CLI supports a dry run for the command you need, prefer it before production.

## Drift / repair

- Inspect local vs remote migration history:
  - `npx supabase migration list`
- Only use `npx supabase migration repair ...` after understanding drift cause.
- Verify exact flags on installed CLI with:
  - `npx supabase migration repair --help`

Typical case
- Remote history changed manually or failed partway.
- Repair history, then rerun `db push` or `db pull` as appropriate.

## Dumps / backup

Schema dump:
- `npx supabase db dump -f supabase/schema.sql`

Data-only dump:
- `npx supabase db dump --data-only -f supabase/data.sql`

Local seed snapshot before destructive local reset/upgrade:
- `npx supabase db dump --local --data-only > supabase/seed.sql`

## Generated types

TypeScript:
- `npx supabase gen types typescript --project-id "$PROJECT_REF" > src/lib/database.types.ts`

Use when
- repo checks in DB types
- schema changed
- app code imports generated database types

## Known failure

`db pull` permission error on old hosted projects:
- error may mention `permission denied for table _type`
- official docs point to ownership drift in graphql objects
- fix ownership on affected objects, then rerun `db pull`
