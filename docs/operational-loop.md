# Operational Loop (Draft)

This defines the minimal operating cycle for OpenClaw and the human operator.

## 1. Capture (Intake)
- All new inputs enter via the INBOX surface (Telegram/WhatsApp).
- No planning, no execution here.

## 2. Route (Domain Selection)
- Determine domain ownership.
- Route to the correct Slack channel by domain.

## 3. Discuss (Workspace)
- Discuss only within the owning domain channel.
- Use threads for multi-step reasoning.
- End discussion with a concise summary.

## 4. Persist (Brain)
- Convert outcomes to neutral, personality-free memory.
- Structured objects (tasks/decisions/events/actions) go to SQLite: `state/brain.db`.
- Freeform notes/specs go to Markdown under `brain/`.
- Prefer update over new file creation.
- Regenerate projections: `make projections`.

## 5. Log (Governance)
- If a decision is made, store it in SQLite (`decisions`) and regenerate projections.
- All material DB changes must have an `audit_logs` entry (via tooling/runtime).
- If schema/spec changes, update `brain/changelog.md`.

## 6. Confirm (Interface)
- Send a brief confirmation to the intake surface referencing where the outcome lives.

## 7. Review (Maintenance)
- Periodically verify repo integrity with `make validate`.
- Periodically verify DB integrity with `make db-check`.
- Regenerate projections with `make projections` when needed.
- Perform the first-run self-test after bootstraps or major refactors.
