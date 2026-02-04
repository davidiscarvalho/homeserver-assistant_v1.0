# Governance (Draft)

This defines how the system evolves without drift.

## Scope
- `brain/` is canonical memory. Changes here are authoritative.
- `docs/` is reference-only. It must align with the canonical brain.

## Change Rules
- Prefer updating existing files over creating new ones.
- Any structural change to `brain/` must be logged in:
  - `brain/decisions/decision_log.md`
  - `brain/changelog.md`
- Any material change to `docs/` must be logged in `docs/CHANGELOG.md`.

## Memory Neutrality
- Memory must be neutral, factual, and personality-free.
- Personality may appear only in interface layers, not in `brain/`.

## Validation
- Run `make validate` after changes to `brain/`.
- Fix schema drift immediately if validation fails.

## Exceptions
- Emergency fixes are allowed but must be logged retroactively.
