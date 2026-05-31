#!/usr/bin/env bash
# Emit proof-db/export-math.json for proof-library ingest (Phase 7 WP-RS-05).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${1:-proof-db/export-math.json}"
python3 scripts/export-math.py --pretty -o "$OUT"
echo "proof-library-export-snapshot: OK → $OUT"
