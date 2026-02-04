#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRAIN_DIR="$ROOT_DIR/brain"

required_files=(
  "$BRAIN_DIR/README.md"
  "$BRAIN_DIR/core-spec.md"
  "$BRAIN_DIR/principles.md"
  "$BRAIN_DIR/ontology.md"
  "$BRAIN_DIR/inbox.md"
  "$BRAIN_DIR/workflows/thinking.md"
  "$BRAIN_DIR/workflows/planning.md"
  "$BRAIN_DIR/workflows/execution.md"
  "$BRAIN_DIR/memory/short_term.md"
  "$BRAIN_DIR/memory/long_term.md"
  "$BRAIN_DIR/memory/archival_rules.md"
  "$BRAIN_DIR/memory/entry-template.md"
  "$BRAIN_DIR/decisions/decision_log.md"
  "$BRAIN_DIR/changelog.md"
  "$BRAIN_DIR/trust-action-policy.md"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "MISSING: $file"
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "FAIL: brain schema missing required files."
  exit 1
fi

# Check for unexpected files (ignore hidden files and folders)
expected_set="$(printf "%s\n" "${required_files[@]}")"
actual_set="$(find "$BRAIN_DIR" -type f -not -path '*/.*' | sort)"
extra=0
while IFS= read -r file; do
  if ! grep -Fxq "$file" <<< "$expected_set"; then
    echo "UNEXPECTED: $file"
    extra=1
  fi
done <<< "$actual_set"

if [[ $extra -ne 0 ]]; then
  echo "FAIL: brain schema has unexpected files."
  exit 1
fi

echo "OK: brain schema files present and no unexpected files found."
