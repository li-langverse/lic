#!/usr/bin/env bash
# Serve World Studio HTML demo showcase locally.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${1:-8765}"
DEMO="$ROOT/deploy/studio-demo"

chmod +x "$ROOT/scripts/gen-studio-demo-status.sh"
"$ROOT/scripts/gen-studio-demo-status.sh"

echo "World Studio demo: http://127.0.0.1:${PORT}/"
echo "  autoreel: http://127.0.0.1:${PORT}/?autoreel=1"
echo "  publish:  http://127.0.0.1:${PORT}/?demo=publish"
exec python3 -m http.server "$PORT" --directory "$DEMO"
