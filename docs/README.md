# System Reference Docs

These documents describe system behavior and interaction surfaces. They are **not** memory.
Canonical memory lives in:
- Markdown: `brain/` (freeform notes/specs)
- SQLite: `state/brain.db` (structured objects)

## Contents
- `messaging-architecture.md` — Messaging architecture and routing rules
- `personality-snippy.md` — Snippy persona and tone guidance (interface layer only)
- `first-run-self-test.md` — Mandatory first-boot integrity test
- `bootstrap-checklist.md` — One-stop initialization checklist
- `governance.md` — Rules for changing the brain, DB schema, and docs
- `operational-loop.md` — Minimal capture → discuss → persist → log cycle
- `routing-map.md` — Slack channel → canonical targets mapping

## Canonical Memory
- `../brain/README.md` — Brain schema (authoritative)
- `../brain/core-spec.md` — Authority & system model
- `../brain/trust-action-policy.md` — Action boundaries
- `../brain/db/README.md` — Structured brain DB spec

## Validation
Run:
- `make validate` (schema/files)
- `make db-init` / `make db-check` (SQLite)
- `make projections` (generate views)
- `make backup` / `make restore BACKUP=...` (encrypted backups)
