# Bootstrap Checklist

Say: "Check bootstrap" and verify each item below.

## 1. Schema Integrity
- Run: `make validate`
- Expected: OK message, no missing or unexpected files

## 2. First-Run Self-Test
- Follow: `docs/first-run-self-test.md`
- If any check fails, log it as a decision and note the fix.

## 3. Initial Decision Log
- Run: `scripts/new_decision_entry.sh`
- Record: "Initialized OpenClaw in homeserver environment" (or equivalent)

## 4. Changelog Entry
- Append to: `brain/changelog.md`
- Example: "2026-02-04 — OpenClaw bootstrapped and validated"

## 5. Operational Loop Ready
- Confirm: `docs/operational-loop.md` exists and is understood
- Confirm: `docs/routing-map.md` maps Slack channels to brain paths

## 6. Governance Baseline
- Confirm: `docs/governance.md` exists and has been read

If all items pass, the system is considered initialized.
