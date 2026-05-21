#!/usr/bin/env bash
# Open Li World Studio design preview (no PNGs in repo).
# Usage:
#   ./scripts/open-studio-design-preview.sh           # interactive HTML (canonical)
#   ./scripts/open-studio-design-preview.sh --gallery # local screenshots in .artifacts/
#   ./scripts/open-studio-design-preview.sh --capture # capture then open gallery
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="$ROOT/deploy/studio-demo"
MODE="${1:-}"

open_url() {
  local url="$1"
  if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$url"
  elif command -v open >/dev/null 2>&1; then
    open "$url"
  else
    echo "Open in browser: $url"
  fi
}

case "$MODE" in
  --capture)
    "$ROOT/scripts/capture-studio-mockup-screenshots.sh"
    open_url "file://$ROOT/.artifacts/studio-mockups/preview.html"
    ;;
  --gallery)
    if [[ ! -f "$ROOT/.artifacts/studio-mockups/preview.html" ]]; then
      echo "No gallery yet. Run: $0 --capture" >&2
      exit 1
    fi
    open_url "file://$ROOT/.artifacts/studio-mockups/preview.html"
    ;;
  ""|--demo)
    if [[ ! -f "$DEMO/index.html" ]]; then
      echo "Missing $DEMO/index.html" >&2
      exit 1
    fi
    echo "Interactive prototype (source of truth): file://$DEMO/index.html"
    open_url "file://$DEMO/index.html"
    ;;
  *)
    echo "usage: $0 [--demo|--gallery|--capture]" >&2
    exit 1
    ;;
esac
