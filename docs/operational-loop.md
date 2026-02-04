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
- Store in the canonical `brain/` vault.
- Prefer update over new file creation.

## 5. Log (Governance)
- If a decision is made, append to `brain/decisions/decision_log.md`.
- If memory or structure changes, update `brain/changelog.md`.

## 6. Confirm (Interface)
- Send a brief confirmation to the intake surface referencing where the outcome lives.

## 7. Review (Maintenance)
- Periodically verify vault integrity with `scripts/validate_brain_schema.sh`.
- Perform the first-run self-test after bootstraps or major refactors.
