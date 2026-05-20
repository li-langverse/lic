#!/usr/bin/env bash
# Timed world/replication/physics-frame benches (competitive gaming path).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RUNS="${LI_BENCH_RUNS:-3}"
export LI_BENCH_QUICK="${LI_BENCH_QUICK:-1}"
OUT="${LI_BENCH_CSV:-$ROOT/benchmarks/results/world_engine.csv}"

echo "== tier2 world_engine (quick=${LI_BENCH_QUICK}) runs=${RUNS} =="
python3 benchmarks/harness/bench.py --tier 2 --quick --runs "$RUNS" --out "$OUT"
python3 benchmarks/harness/validity.py --tier 2 --quick 2>&1 | rg 'game_world|game_replication|sim_physics|wrote' || true
