# Encrypted Backups

This folder contains encrypted SQLite database snapshots.

## Format
- `brain-YYYYMMDD.db.age`

## Create
- Set `AGE_RECIPIENT` (public key) in your environment or `secrets/openclaw.env`.
- Run: `make backup`

## Restore
- Set `AGE_IDENTITY_FILE` (private key file path) in your environment or `secrets/openclaw.env`.
- Run: `make restore BACKUP=backups/brain-YYYYMMDD.db.age`

## Notes
- Plaintext database backups must never be committed.
