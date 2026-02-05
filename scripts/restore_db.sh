#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH="${BRAIN_DB_PATH:-$ROOT_DIR/state/brain.db}"

if ! command -v age >/dev/null 2>&1; then
  echo "ERROR: age is not installed." >&2
  exit 1
fi

backup="${1:-${BACKUP:-}}"
if [[ -z "$backup" ]]; then
  echo "ERROR: missing backup path. Usage: make restore BACKUP=backups/brain-YYYYMMDD.db.age" >&2
  exit 1
fi

if [[ ! -f "$backup" ]]; then
  echo "ERROR: backup not found: $backup" >&2
  exit 1
fi

identity="${AGE_IDENTITY_FILE:-}"
if [[ -z "$identity" ]]; then
  echo "ERROR: AGE_IDENTITY_FILE is not set (see secrets/example.env)." >&2
  exit 1
fi

if [[ ! -f "$identity" ]]; then
  echo "ERROR: identity file not found: $identity" >&2
  exit 1
fi

mkdir -p "$(dirname "$DB_PATH")"

if [[ -f "$DB_PATH" ]]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  cp "$DB_PATH" "$DB_PATH.bak-$ts"
  echo "Saved existing DB to $DB_PATH.bak-$ts"
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

age -d -i "$identity" -o "$tmp" "$backup"

mv "$tmp" "$DB_PATH"
# Disable trap cleanup since we moved it.
trap - EXIT

echo "OK: restored DB to $DB_PATH"
