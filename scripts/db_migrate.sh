#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH="${BRAIN_DB_PATH:-$ROOT_DIR/state/brain.db}"
MIGRATIONS_DIR="$ROOT_DIR/brain/db/migrations"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "ERROR: sqlite3 is not installed. Install it first (e.g., 'apt install sqlite3' on Ubuntu)." >&2
  exit 1
fi

if [[ ! -f "$DB_PATH" ]]; then
  "$ROOT_DIR/scripts/db_init.sh"
fi

current_version_raw="$(sqlite3 "$DB_PATH" "SELECT value FROM meta WHERE key='schema_version' LIMIT 1;")"
current_version_raw="${current_version_raw:-0}"
current_version=$((10#$current_version_raw))

# Apply migrations in numeric order (0001_*.sql, 0002_*.sql, ...)
shopt -s nullglob
migrations=("$MIGRATIONS_DIR"/[0-9][0-9][0-9][0-9]_*.sql)

applied_any=0
for file in "${migrations[@]}"; do
  base="$(basename "$file")"
  version="${base:0:4}"
  version_num=$((10#$version))

  if [[ "$version_num" -le "$current_version" ]]; then
    continue
  fi

  name="${base%.sql}"

  sqlite3 "$DB_PATH" <<EOF_SQL
BEGIN;
.read '$file'
INSERT OR IGNORE INTO schema_migrations(name) VALUES ('$name');
INSERT OR REPLACE INTO meta(key, value) VALUES ('schema_version', '$version_num');
COMMIT;
EOF_SQL

  current_version="$version_num"
  applied_any=1
  echo "Applied migration: $name"
done

if [[ $applied_any -eq 0 ]]; then
  echo "OK: no migrations to apply (schema_version=$current_version)"
else
  echo "OK: schema_version=$current_version"
fi
