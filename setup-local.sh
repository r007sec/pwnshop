#!/usr/bin/env bash
set -euo pipefail

# Load DB password from .env.lab
if [[ -f .env.lab ]]; then
  export $(grep -v '^#' .env.lab | xargs)
fi

DB_PASSWORD="${DB_PASSWORD:-password}"

echo "Starting PwnShop local setup..."

# Bring down any existing containers and volumes
docker compose --env-file .env.lab -f docker/docker-compose.lab.yml down -v 2>/dev/null || true

# Build and start
docker compose --env-file .env.lab -f docker/docker-compose.lab.yml up --build -d

echo "Waiting for database to be ready..."
until docker exec docker-db-1 mysqladmin ping -u root -p"${DB_PASSWORD}" --silent 2>/dev/null; do
  printf "."
  sleep 2
done
echo ""

echo "Importing database..."
docker exec -i docker-db-1 mysql -u root -p"${DB_PASSWORD}" pwnshop < pwnshop.sql

echo "Copying seed images..."
UPLOADS_VOLUME=$(docker volume inspect docker_uploads_data --format '{{.Mountpoint}}')
sudo cp public/uploads-seed/* "$UPLOADS_VOLUME"/
sudo chown -R 999:999 "$UPLOADS_VOLUME"/

echo ""
echo "PwnShop is ready! Visit http://localhost:3000"
