#!/usr/bin/env bash
# WP-DS-03 — baseline.jsonl synced with catalog (BUG-C-06/07).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

if [[ ! -f proof-db/baseline.jsonl ]]; then
  echo "wp-baseline-sync: missing proof-db/baseline.jsonl" >&2
  exit 1
fi

python3 scripts/proof-db/proof-db.py verify-slice
echo "wp-baseline-sync: verify-slice OK"

if [[ -x scripts/check-proof-db.sh ]]; then
  bash scripts/check-proof-db.sh
  echo "wp-baseline-sync: check-proof-db OK"
fi

lines="$(wc -l < proof-db/baseline.jsonl | tr -d ' ')"
if [[ "$lines" -lt 100 ]]; then
  echo "wp-baseline-sync: baseline.jsonl too small ($lines lines)" >&2
  exit 1
fi

echo "wp-baseline-sync: OK ($lines baseline rows)"
