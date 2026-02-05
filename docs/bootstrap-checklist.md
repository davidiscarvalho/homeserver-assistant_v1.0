# Bootstrap Checklist (Brain v2)

Say: "Check bootstrap" and verify each item below.

## 1. Repo Schema Integrity
- Run: `make validate`
- Expected: OK message, no missing required files/dirs

## 2. Secrets Setup (Local)
- Create `secrets/openclaw.env` (gitignored) with real values (use `secrets/example.env` as a template).
- Confirm `git status` does not show any secrets files.

## 3. SQLite Init
- Run: `make db-init`
- Expected: creates `state/brain.db` (gitignored)

## 4. SQLite Health
- Run: `make db-check`
- Expected: `integrity_check` ok; required tables exist

## 5. Generate Projections
- Run: `make projections`
- Expected: updates `brain/projections/**` (generated, read-only)

## 6. First-Run Self-Test
- Follow: `docs/first-run-self-test.md`
- If any check fails, log it and fix it before continuing.

## 7. Encrypted Backup (Recommended)
- Install `age` and set `AGE_RECIPIENT` (see `secrets/example.env`)
- Run: `make backup`
- Expected: `backups/brain-YYYYMMDD.db.age` created

## 8. Governance Baseline
- Confirm: `docs/governance.md` exists and has been read.
- Confirm: `docs/operational-loop.md` and `docs/routing-map.md` reflect the DB + Markdown split.

If all items pass, the system is considered initialized.
