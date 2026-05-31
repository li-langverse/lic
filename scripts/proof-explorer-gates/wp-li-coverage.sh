#!/usr/bin/env bash
# WP-LC — Li formalization coverage audit (Phase 4).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 scripts/formalization/check-li-coverage.py \
  --json-out data/proof-explorer-loop/li-coverage-report.json \
  --min-t0 100 \
  --min-t1 100 \
  --min-t2 100
