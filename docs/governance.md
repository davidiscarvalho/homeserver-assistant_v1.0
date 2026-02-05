# Governance (Brain v2)

This defines how the system evolves without drift.

## Scope
- `brain/` (Markdown) is canonical for freeform notes/specs.
- `state/brain.db` (SQLite, gitignored) is canonical for structured objects.
- `brain/projections/` is generated from SQLite and is read-only.
- `docs/` is reference-only; it must align with the canonical brain.

## Change Rules (General)
- Prefer updating existing files over creating new ones.
- Any structural or semantic change must be logged in:
- `brain/changelog.md` (brain schema/spec changes)
- `docs/CHANGELOG.md` (reference doc changes)

## SQLite Schema & Migrations
- Schema definition lives in `brain/db/` (committed text).
- Migrations are append-only:
- Add new migration files under `brain/db/migrations/` (e.g., `0002_add_foo.sql`).
- Apply with `make db-migrate`.
- Do not edit old migration files after they’ve been applied.
- `meta.schema_version` tracks the last applied migration.

## Projections
- Projection definitions live in `brain/db/projections/`.
- Projection outputs live in `brain/projections/`.
- Outputs are generated with `make projections` and must not be edited by hand.
- If output is wrong, fix DB data or projection SQL/renderer and regenerate.

## Secrets & Credentials (Non-Negotiable)
- Secrets must live in `secrets/` (gitignored) and must never be committed.
- `integrations.config` in SQLite must store only a pointer/path/key to the secret (never the secret itself).
- Any leaked secret requires rotation and a logged incident note.

## Backups
- Encrypted DB snapshots are committed to `backups/*.age`.
- Plaintext DB backups must never be committed.
- Restore uses `make restore BACKUP=...` and should be treated as a high-impact action.

## Validation
- Run `make validate` after changes to schema/docs/scripts.
- Run `make db-check` after DB migrations.
- Fix drift immediately if validation fails.

## Exceptions
- Emergency fixes are allowed but must be logged retroactively in changelogs.

