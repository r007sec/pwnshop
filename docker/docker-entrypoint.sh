#!/usr/bin/env bash
set -euo pipefail

UPLOADS_DIR="/usr/src/app/public/uploads"

mkdir -p "$UPLOADS_DIR"
chmod -R u+rwX,go+rwX "$UPLOADS_DIR" 2>/dev/null || true

if [[ $# -eq 0 ]]; then
  set -- node src/app.js
fi

exec "$@"
