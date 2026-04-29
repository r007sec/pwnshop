#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.lab"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/healer.log"

# Preserve explicit shell override like: HEAL_EVERY_MINUTES=20 ./scripts/setup-healer-cron.sh
HEAL_EVERY_MINUTES_OVERRIDE="${HEAL_EVERY_MINUTES:-}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy .env.lab.example to .env.lab first." >&2
  exit 1
fi

set -a
# shellcheck source=/dev/null
source "$ENV_FILE"
set +a

HEAL_EVERY_MINUTES="${HEAL_EVERY_MINUTES_OVERRIDE:-${HEAL_EVERY_MINUTES:-10}}"
if ! [[ "$HEAL_EVERY_MINUTES" =~ ^[0-9]+$ ]] || [[ "$HEAL_EVERY_MINUTES" -lt 10 ]] || [[ "$HEAL_EVERY_MINUTES" -gt 59 ]]; then
  echo "HEAL_EVERY_MINUTES must be an integer between 10 and 59" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

CMD="cd $PROJECT_ROOT && docker compose --env-file .env.lab -f docker/docker-compose.lab.yml exec -T app /bin/bash /usr/src/app/scripts/reset-lab-inside.sh >> $LOG_FILE 2>&1"
CRON_LINE="*/$HEAL_EVERY_MINUTES * * * * $CMD"

{
  (crontab -l 2>/dev/null || true) | grep -Fv '/usr/src/app/scripts/reset-lab-inside.sh' || true
  echo "$CRON_LINE"
} | crontab -

echo "Installed healer cron: every $HEAL_EVERY_MINUTES minute(s)."
echo "Log file: $LOG_FILE"
