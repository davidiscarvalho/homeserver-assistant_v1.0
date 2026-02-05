# OpenClaw Brain DB — Structured Canon (v1.0)

This document defines the SQLite database used by OpenClaw as the **canonical store for structured objects**.

## Authority Model (Brain v2)

- **SQLite (`state/brain.db`) is canonical** for structured objects:
  - tasks, habits, events, actions, decisions, audit logs, integrations registry, projection run metadata
- **Markdown (`brain/…`) is canonical** for freeform knowledge and writing:
  - research notes, long-form notes, policies/specs, tags, wikilinks
- **Projections (`brain/projections/…`) are generated** Markdown views exported from SQLite.
  - Treat projections as **read-only**; if output is wrong, fix the DB or the projection definition and re-run.

## Paths

- Live DB (gitignored): `state/brain.db`
- Schema (text, committed): `brain/db/schema.sql`
- Migrations (committed): `brain/db/migrations/*.sql`
- Projection definitions (committed): `brain/db/projections/`
- Projection outputs (committed): `brain/projections/`
- Encrypted snapshots (committed): `backups/*.age`

## Schema

The initial schema is defined in:
- `brain/db/schema.sql`
- `brain/db/migrations/0001_init.sql`

Key tables:
- `meta` — key/value config and versioning (includes `schema_version`)
- `users` — identities (owner/admin/agent)
- `memories` — structured memory items (facts/knowledge/policy/config/note)
  - `ref_path` links a row to a canonical Markdown note (e.g., `brain/memory/research/YYYY-MM-DD--slug.md`)
- `tasks` — task registry
- `habits`, `habit_events` — habits and events
- `decisions` — explicit decisions (human or agent)
- `actions` — execution records
- `events` — append-only event log
- `integrations` — registry of integrations; configuration must be a **pointer** (never raw secrets)
- `audit_logs` — audit trail for writes
- `projections` — track projection job runs
- `schema_migrations` — applied migrations

## Write / Read Rules (Summary)

Global rules:
- Writes must be transactional.
- Prefer append-first (`events`, `audit_logs`).
- Any state-changing write must create an `audit_logs` entry.
- `integrations.config` must store a pointer (path/key) to a gitignored secret, never the secret itself.

Suggested defaults (enforced by policy/tooling, not by SQLite alone):
- `events`: agent may append without approval.
- `habit_events`: agent may append.
- `tasks`: agent may create tasks; status transitions to `done`/`cancelled` require explicit approval/decision.
- `memories.kind='policy'` and `memories.kind='config'` updates require human decision.
- Projections are generated from DB and must not be edited by hand.

## Projection Jobs

Projection jobs export curated views of DB data into Markdown for fast reading and review.

- Definitions live in: `brain/db/projections/manifest.json`
- SQL queries live in: `brain/db/projections/queries/*.sql`
- Outputs are written to: `brain/projections/**`

Initial projections:
- Tasks backlog: `brain/projections/tasks/backlog.md`
- Recent decisions (7d): `brain/projections/decisions/recent.md`
- System events (24h): `brain/projections/system/events-24h.md`
- Audit changes (24h): `brain/projections/system/audit-24h.md`
- Research index: `brain/projections/research/index.md`

Run: `make projections`

## Operational Notes

- Integrity check: `make db-check`
- Backup (encrypted): `make backup`
- Restore: `make restore BACKUP=backups/brain-YYYYMMDD.db.age`
