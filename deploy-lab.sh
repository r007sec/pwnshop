#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.lab"

if [[ ! -f "$ENV_FILE" ]]; then
  cp "$PROJECT_ROOT/.env.lab.example" "$ENV_FILE"
  echo "Created .env.lab from template. Update LAB_RESET_TOKEN before exposing the lab."
fi

set -a
# shellcheck source=/dev/null
source "$ENV_FILE"
set +a

if [[ -z "${LAB_RESET_TOKEN:-}" ]] || [[ "${LAB_RESET_TOKEN}" == "change-this-reset-token" ]]; then
  echo "Set LAB_RESET_TOKEN in .env.lab to a strong random value before deploy." >&2
  exit 1
fi

cd "$PROJECT_ROOT"
docker compose --env-file .env.lab -f docker/docker-compose.lab.yml up -d --build

# One initial reset to guarantee clean starting state
reset_ok=0
for attempt in 1 2 3; do
  if docker compose --env-file .env.lab -f docker/docker-compose.lab.yml exec -T app /bin/bash /usr/src/app/scripts/reset-lab-inside.sh; then
    reset_ok=1
    break
  fi
  echo "Initial reset attempt $attempt failed; retrying in 5 seconds..."
  sleep 5
done

if [[ "$reset_ok" -ne 1 ]]; then
  echo "Initial reset failed after retries. Containers are running, but run manual reset after checking logs." >&2
  exit 1
fi

echo "Lab deployed: http://SERVER_IP:3000"
echo "Manual reset endpoint: POST /lab/reset with header x-lab-reset-token: $LAB_RESET_TOKEN"
echo "Reset cooldown: one successful reset every 10 minutes"
