# Routing Map (Brain v2)

This maps Slack domain channels to canonical storage locations.

- Structured objects are canonical in SQLite (`state/brain.db`).
- Freeform notes/specs are canonical in Markdown (`brain/`).
- Projections are generated in `brain/projections/`.

## Channels → Canonical Targets

- `#openclaw-todo`:
  - SQLite: `tasks`, `actions`, `events`
  - Projections: `brain/projections/tasks/backlog.md`
  - Notes: `brain/memory/short_term.md` (working notes), `brain/memory/long_term.md` (stable rules)

- `#openclaw-decisions`:
  - SQLite: `decisions`, `audit_logs`
  - Projections: `brain/projections/decisions/recent.md`
  - Notes/spec: `brain/decisions/decision_log.md` (legacy/templates only)

- `#openclaw-calendar`:
  - SQLite: `events` (calendar.*)
  - Notes: `brain/memory/short_term.md` (near-term scheduling notes)

- `#openclaw-mail-*` (outlook/gmail/resumai):
  - SQLite: `events` (email.*), `memories` (rules/policies)
  - Notes: `brain/memory/long_term.md` (mail rules and summaries)

- `#openclaw-obsidian`:
  - Markdown system spec: `brain/README.md`, `brain/core-spec.md`, `brain/ontology.md`, `brain/principles.md`, `brain/workflows/*`
  - DB spec: `brain/db/**`

- `#openclaw-archive`:
  - Policy: `brain/memory/archival_rules.md`
  - Projections: `brain/projections/system/*` (optional operational views)

## Notes
- Do not treat Slack as storage.
- Decisions and tasks are canonical in SQLite and should appear in projections after `make projections`.
- Freeform reasoning summaries can live as Markdown notes, but structured outcomes must be in SQLite.

