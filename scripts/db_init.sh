#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH="${BRAIN_DB_PATH:-$ROOT_DIR/state/brain.db}"
INIT_SQL="$ROOT_DIR/brain/db/migrations/0001_init.sql"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "ERROR: sqlite3 is not installed. Install it first (e.g., 'apt install sqlite3' on Ubuntu)." >&2
  exit 1
fi

mkdir -p "$(dirname "$DB_PATH")"

if [[ -f "$DB_PATH" ]]; then
  echo "OK: DB already exists at $DB_PATH"
  exit 0
fi

if [[ ! -f "$INIT_SQL" ]]; then
  echo "ERROR: init migration not found: $INIT_SQL" >&2
  exit 1
fi

# Apply the initial schema.
sqlite3 "$DB_PATH" <<EOF_SQL
BEGIN;
.read '$INIT_SQL'
INSERT OR REPLACE INTO meta(key, value) VALUES ('schema_version', '1');
INSERT OR REPLACE INTO meta(key, value) VALUES ('autonomy_confidence_threshold', '0.9');
INSERT OR REPLACE INTO meta(key, value) VALUES ('projection_policy', 'no-secrets');
INSERT OR IGNORE INTO schema_migrations(name) VALUES ('0001_init');
INSERT INTO users(name, role)
  SELECT 'owner', 'owner'
  WHERE NOT EXISTS (SELECT 1 FROM users WHERE role = 'owner');
COMMIT;
EOF_SQL

echo "OK: initialized DB at $DB_PATH"
