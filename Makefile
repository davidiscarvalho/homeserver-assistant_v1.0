.PHONY: validate db-init db-migrate db-check projections backup restore

validate:
	./scripts/validate_brain_schema.sh

db-init:
	./scripts/db_init.sh

db-migrate:
	./scripts/db_migrate.sh

db-check:
	./scripts/db_check.sh

projections:
	python3 ./scripts/projections_run.py

backup:
	./scripts/backup_db.sh

restore:
	./scripts/restore_db.sh "$(BACKUP)"
