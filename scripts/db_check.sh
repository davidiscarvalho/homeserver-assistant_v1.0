#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH="${BRAIN_DB_PATH:-$ROOT_DIR/state/brain.db}"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "ERROR: sqlite3 is not installed. Install it first (e.g., 'apt install sqlite3' on Ubuntu)." >&2
  exit 1
fi

if [[ ! -f "$DB_PATH" ]]; then
  echo "ERROR: DB not found at $DB_PATH (run 'make db-init')" >&2
  exit 1
fi

integrity="$(sqlite3 "$DB_PATH" "PRAGMA integrity_check;")"
if [[ "$integrity" != "ok" ]]; then
  echo "FAIL: PRAGMA integrity_check returned: $integrity" >&2
  exit 1
fi

required_tables=(
  meta
  users
  memories
  tasks
  habits
  habit_events
  decisions
  actions
  events
  integrations
  audit_logs
  projections
  schema_migrations
)

missing=0
for t in "${required_tables[@]}"; do
  exists="$(sqlite3 "$DB_PATH" "SELECT 1 FROM sqlite_master WHERE type='table' AND name='$t' LIMIT 1;")"
  if [[ -z "$exists" ]]; then
    echo "MISSING TABLE: $t" >&2
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "FAIL: missing required tables." >&2
  exit 1
fi

echo "OK: DB integrity_check ok; required tables present."
