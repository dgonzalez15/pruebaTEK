#!/usr/bin/env zsh
set -euo pipefail

# Ajusta BASE si ejecutas desde otra ubicación
BASE="$(cd "$(dirname "$0")" && pwd)"
BACKEND="$BASE/reporteria-peluqueria/backend-api"
FRONTEND="$BASE/reporteria-peluqueria/frontend"
RUNTIME="$BASE/runtime"
LOGS="$BASE/logs"

mkdir -p "$RUNTIME" "$LOGS"

echo "Iniciando backend..."
cd "$BACKEND"
# Ejecuta php artisan serve en background y guarda PID/log
php artisan serve --host=127.0.0.1 --port=8000 > "$LOGS/backend.log" 2>&1 &
echo $! > "$RUNTIME/backend.pid"

sleep 1

echo "Iniciando frontend..."
cd "$FRONTEND"
# npm start (ng serve) en background
npm install --no-audit --no-fund >/dev/null 2>&1 || true
npm start > "$LOGS/frontend.log" 2>&1 &
echo $! > "$RUNTIME/frontend.pid"

sleep 1

echo "Servicios levantados:"
echo "  Backend PID: $(cat "$RUNTIME/backend.pid")  (logs: $LOGS/backend.log)"
echo "  Frontend PID: $(cat "$RUNTIME/frontend.pid") (logs: $LOGS/frontend.log)"
echo ""
echo "Para ver logs en tiempo real:"
echo "  tail -f $LOGS/backend.log $LOGS/frontend.log"

action() {
  echo "Deteniendo procesos..."
  if [[ -f "$RUNTIME/backend.pid" ]]; then
    kill "$(cat "$RUNTIME/backend.pid")" 2>/dev/null || true
    rm -f "$RUNTIME/backend.pid"
  fi
  if [[ -f "$RUNTIME/frontend.pid" ]]; then
    kill "$(cat "$RUNTIME/frontend.pid")" 2>/dev/null || true
    rm -f "$RUNTIME/frontend.pid"
  fi
  exit 0
}

trap action INT TERM

# Mantener el script vivo hasta que el usuario haga Ctrl+C
wait
