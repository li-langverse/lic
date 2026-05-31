#!/usr/bin/env bash
# WP-DS-03 — baseline.jsonl synced with catalog (BUG-C-06/07).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

# Regenerate Lean theorem baseline when export drifts
if [[ -x scripts/export-proof-db.sh ]]; then
  bash scripts/export-proof-db.sh > proof-db/baseline.jsonl
  echo "wp-baseline-sync: regenerated proof-db/baseline.jsonl"
fi

python3 scripts/export-catalog-baseline.py

if [[ ! -f proof-db/baseline.jsonl ]]; then
  echo "wp-baseline-sync: missing proof-db/baseline.jsonl" >&2
  exit 1
fi

if [[ ! -f proof-db/catalog-baseline.jsonl ]]; then
  echo "wp-baseline-sync: missing proof-db/catalog-baseline.jsonl" >&2
  exit 1
fi

python3 scripts/proof-db/proof-db.py verify-slice
echo "wp-baseline-sync: verify-slice OK"

if [[ -x scripts/check-proof-db.sh ]]; then
  bash scripts/check-proof-db.sh
  echo "wp-baseline-sync: check-proof-db OK"
fi

lean_lines="$(wc -l < proof-db/baseline.jsonl | tr -d ' ')"
catalog_lines="$(wc -l < proof-db/catalog-baseline.jsonl | tr -d ' ')"
if [[ "$lean_lines" -lt 10 ]]; then
  echo "wp-baseline-sync: baseline.jsonl too small ($lean_lines lines)" >&2
  exit 1
fi
if [[ "$catalog_lines" -lt 100 ]]; then
  echo "wp-baseline-sync: catalog-baseline.jsonl too small ($catalog_lines lines)" >&2
  exit 1
fi

echo "wp-baseline-sync: OK (lean=$lean_lines catalog=$catalog_lines baseline rows)"
