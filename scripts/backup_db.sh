#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH="${BRAIN_DB_PATH:-$ROOT_DIR/state/brain.db}"
BACKUPS_DIR="$ROOT_DIR/backups"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "ERROR: sqlite3 is not installed." >&2
  exit 1
fi

if ! command -v age >/dev/null 2>&1; then
  echo "ERROR: age is not installed. Install it first (e.g., 'apt install age' on Ubuntu)." >&2
  exit 1
fi

if [[ ! -f "$DB_PATH" ]]; then
  echo "ERROR: DB not found at $DB_PATH" >&2
  exit 1
fi

if [[ -z "${AGE_RECIPIENT:-}" ]]; then
  echo "ERROR: AGE_RECIPIENT is not set (see secrets/example.env)." >&2
  exit 1
fi

mkdir -p "$BACKUPS_DIR"

stamp="$(date +%Y%m%d)"
out="$BACKUPS_DIR/brain-${stamp}.db.age"
if [[ -f "$out" ]]; then
  # Avoid overwrite when running multiple times in the same day.
  n=2
  while [[ -f "$BACKUPS_DIR/brain-${stamp}-${n}.db.age" ]]; do
    n=$((n + 1))
  done
  out="$BACKUPS_DIR/brain-${stamp}-${n}.db.age"
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Create a consistent snapshot.
sqlite3 "$DB_PATH" ".backup $tmp"

age -r "$AGE_RECIPIENT" -o "$out" "$tmp"

echo "OK: wrote encrypted backup: $out"
