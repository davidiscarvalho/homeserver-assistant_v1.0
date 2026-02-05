#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "$ROOT_DIR/brain/README.md"
  "$ROOT_DIR/brain/core-spec.md"
  "$ROOT_DIR/brain/principles.md"
  "$ROOT_DIR/brain/ontology.md"
  "$ROOT_DIR/brain/trust-action-policy.md"

  "$ROOT_DIR/brain/db/README.md"
  "$ROOT_DIR/brain/db/schema.sql"
  "$ROOT_DIR/brain/db/migrations/0001_init.sql"
  "$ROOT_DIR/brain/db/projections/manifest.json"

  "$ROOT_DIR/docs/bootstrap-checklist.md"
  "$ROOT_DIR/docs/first-run-self-test.md"
  "$ROOT_DIR/docs/governance.md"

  "$ROOT_DIR/state/README.md"
  "$ROOT_DIR/artifacts/README.md"
  "$ROOT_DIR/backups/README.md"

  "$ROOT_DIR/secrets/README.md"
  "$ROOT_DIR/secrets/example.env"

  "$ROOT_DIR/Makefile"
  "$ROOT_DIR/.gitignore"
)

required_dirs=(
  "$ROOT_DIR/brain/projections"
  "$ROOT_DIR/brain/memory/research"
  "$ROOT_DIR/brain/db/projections/queries"
  "$ROOT_DIR/scripts"
  "$ROOT_DIR/state"
  "$ROOT_DIR/artifacts"
  "$ROOT_DIR/backups"
  "$ROOT_DIR/secrets"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "MISSING FILE: $file" >&2
    missing=1
  fi
done

for dir in "${required_dirs[@]}"; do
  if [[ ! -d "$dir" ]]; then
    echo "MISSING DIR: $dir" >&2
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "FAIL: missing required files/dirs." >&2
  exit 1
fi

# Keep the markdown brain text-only: DB files must not be stored under brain/.
if find "$ROOT_DIR/brain" -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) | grep -q .; then
  echo "FAIL: found SQLite files under brain/ (brain/ must be text-only)." >&2
  find "$ROOT_DIR/brain" -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) >&2
  exit 1
fi

# Ensure critical gitignore rules exist (so secrets/state/artifacts aren't committed).
gitignore="$ROOT_DIR/.gitignore"
must_contain=(
  "/state/brain.db"
  "/artifacts/*"
  "/secrets/*"
)

for pattern in "${must_contain[@]}"; do
  if ! grep -Fqx "$pattern" "$gitignore"; then
    echo "FAIL: .gitignore missing required pattern: $pattern" >&2
    exit 1
  fi
done

# Ensure key scripts are executable.
exec_scripts=(
  "$ROOT_DIR/scripts/db_init.sh"
  "$ROOT_DIR/scripts/db_migrate.sh"
  "$ROOT_DIR/scripts/db_check.sh"
  "$ROOT_DIR/scripts/projections_run.py"
  "$ROOT_DIR/scripts/backup_db.sh"
  "$ROOT_DIR/scripts/restore_db.sh"
)

for s in "${exec_scripts[@]}"; do
  if [[ ! -x "$s" ]]; then
    echo "FAIL: script is not executable: $s" >&2
    exit 1
  fi
done

echo "OK: brain v2 schema checks passed."

