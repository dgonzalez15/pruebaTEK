#!/usr/bin/env zsh
BASE="$(cd "$(dirname "$0")" && pwd)"
RUNTIME="$BASE/runtime"

if [[ -f "$RUNTIME/backend.pid" ]]; then
  kill "$(cat "$RUNTIME/backend.pid")" 2>/dev/null || true
  rm -f "$RUNTIME/backend.pid"
  echo "Backend detenido"
else
  echo "No se encontró PID de backend"
fi

if [[ -f "$RUNTIME/frontend.pid" ]]; then
  kill "$(cat "$RUNTIME/frontend.pid")" 2>/dev/null || true
  rm -f "$RUNTIME/frontend.pid"
  echo "Frontend detenido"
else
  echo "No se encontró PID de frontend"
fi
