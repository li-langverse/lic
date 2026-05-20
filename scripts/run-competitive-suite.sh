#!/usr/bin/env bash
# Full competitive suite: tier-12 timing (5 langs) + checksum validity.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RUNS="${LI_BENCH_RUNS:-5}"
OUT="${LI_BENCH_CSV:-$ROOT/benchmarks/results/latest.csv}"

echo "== tier 12 (verify + timing + validity) runs=$RUNS =="
python3 benchmarks/harness/bench.py --tier 12 --runs "$RUNS" --out "$OUT"

echo "== outputs =="
ls -la "$OUT" "$ROOT/benchmarks/results/validity.csv" "$ROOT/benchmarks/results/validity.json" 2>/dev/null || true
