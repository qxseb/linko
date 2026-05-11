#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DEVICE_ID="${1:-}"

LOCAL_IP="$(ipconfig getifaddr en0 || true)"
if [[ -z "$LOCAL_IP" ]]; then
  LOCAL_IP="$(ipconfig getifaddr en1 || true)"
fi

if [[ -z "$LOCAL_IP" ]]; then
  echo "Could not detect local network IP (en0/en1)."
  echo "Connect to Wi-Fi and try again."
  exit 1
fi

echo "Using local backend URL: http://$LOCAL_IP:3001"

cleanup() {
  if [[ -n "${BACKEND_PID:-}" ]]; then
    kill "$BACKEND_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM

(cd server && npm run start) &
BACKEND_PID=$!

sleep 3

if [[ -n "$DEVICE_ID" ]]; then
  flutter run -d "$DEVICE_ID" --dart-define="LINKO_API_BASE_URL=http://$LOCAL_IP:3001"
else
  flutter run --dart-define="LINKO_API_BASE_URL=http://$LOCAL_IP:3001"
fi
