# System Reference Docs

These documents describe system behavior and interaction surfaces. They are **not** memory.
The canonical memory vault lives at `brain/`.

## Contents
- `messaging-architecture.md` — Messaging architecture and routing rules
- `personality-snippy.md` — Snippy persona and tone guidance (interface layer only)
- `first-run-self-test.md` — Mandatory first-boot integrity test

## Canonical Memory
- `../brain/README.md` — Brain schema (authoritative)
- `../brain/core-spec.md` — Authority & system model
- `../brain/trust-action-policy.md` — Action boundaries
- `operational-loop.md` — Minimal capture → discuss → persist → log cycle

## Validation
Run `make validate` to check that the brain schema files are present.
- `routing-map.md` — Channel → brain file mapping

## Helpers
- `../scripts/new_decision_entry.sh` — Append a decision template to the log
- `governance.md` — Rules for changing the brain and docs
- `bootstrap-checklist.md` — One-stop initialization checklist
