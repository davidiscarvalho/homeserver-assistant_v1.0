# Local State

This folder stores machine-local runtime state that must not be committed to git.

## Contents
- `brain.db` (gitignored): the live SQLite database (canonical for structured objects).

## Notes
- Initialize with `make db-init`.
- Verify with `make db-check`.
