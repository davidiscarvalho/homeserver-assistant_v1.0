#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$ROOT_DIR/brain/decisions/decision_log.md"
TODAY="$(date +%Y-%m-%d)"

cat >> "$LOG_FILE" <<EOF_ENTRY

## ${TODAY}
- Context:
- Decision:
- Rationale:
- Consequences:
EOF_ENTRY

echo "Appended decision template for ${TODAY} to ${LOG_FILE}".
