#!/usr/bin/env bash
set -euo pipefail

DB_HOST="${DB_HOST:-db}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-password}"
DB_NAME="${DB_NAME:-pwnshop}"
SQL_FILE="/usr/src/app/pwnshop.sql"
UPLOADS_DIR="/usr/src/app/public/uploads"
SEED_UPLOADS_DIR="/usr/src/app/public/uploads-seed"

wait_for_mysql() {
  local attempts=30
  local sleep_seconds=2
  local i

  for ((i=1; i<=attempts; i++)); do
    if mysql --protocol=tcp -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
      return 0
    fi
    echo "Waiting for MySQL at $DB_HOST ($i/$attempts)..."
    sleep "$sleep_seconds"
  done

  echo "MySQL did not become ready after $((attempts * sleep_seconds)) seconds" >&2
  return 1
}

if [[ ! -f "$SQL_FILE" ]]; then
  echo "Missing SQL snapshot: $SQL_FILE" >&2
  exit 1
fi

wait_for_mysql

mysql --protocol=tcp -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" \
  -e "DROP DATABASE IF EXISTS \`$DB_NAME\`; CREATE DATABASE \`$DB_NAME\`;"

mysql --protocol=tcp -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$SQL_FILE"

mkdir -p "$UPLOADS_DIR"
find "$UPLOADS_DIR" -mindepth 1 -delete

if [[ -d "$SEED_UPLOADS_DIR" ]]; then
  cp -r --no-preserve=mode,ownership "$SEED_UPLOADS_DIR"/. "$UPLOADS_DIR"/
fi

echo "Lab reset finished at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
