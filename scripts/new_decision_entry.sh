#!/usr/bin/env bash
set -euo pipefail

echo "DEPRECATED: Brain v2 stores canonical decisions in SQLite (state/brain.db)." >&2
echo "Use: sqlite3 state/brain.db \"INSERT INTO decisions(context, decision, rationale, made_by, autonomy_level) VALUES (...);\"" >&2
echo "Then run: make projections" >&2
exit 1
