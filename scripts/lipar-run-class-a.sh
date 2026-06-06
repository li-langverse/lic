#!/usr/bin/env bash
# WP-PAR-47 — run Class A tier1 benches only (PR gate profile).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LIC_ROOT="$ROOT"
export LI_REPO_ROOT="$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
# shellcheck source=lib/resolve-lic-bench.sh
source "${BENCHMARKS_ROOT}/scripts/lib/resolve-lic-bench.sh"
export_lic_bench_paths "$LIC_ROOT"

if [[ ! -x "$LIC" ]]; then
  echo "lipar-run-class-a: lic missing at $LIC — run ./scripts/build.sh" >&2
  exit 1
fi

RUNS="${BENCH_RUNS:-3}"
JOBS="${BENCH_JOBS:-$(nproc 2>/dev/null || echo 4)}"
export BENCHMARKS_CSV="${BENCHMARKS_CSV:-$BENCHMARKS_RESULTS/latest.csv}"
mkdir -p "$(dirname "$BENCHMARKS_CSV")"

echo "==> lipar-run-class-a: tier1 Class A (runs=$RUNS jobs=$JOBS LI_PARALLEL=${LI_PARALLEL:-0})"
python3 - "$RUNS" "$BENCHMARKS_CSV" <<'PY'
import os
import sys
from pathlib import Path

runs = int(sys.argv[1])
out = Path(sys.argv[2])
bench_root = Path(os.environ["BENCHMARKS_ROOT"])
harness = bench_root / "harness"
sys.path.insert(0, str(harness))
from bench import TIER1_BENCHES, merge_rows, read_csv, run_benchmark, write_csv

class_a = {"matmul_blocked", "reduce_sum", "simd_dot"}
specs = [s for s in TIER1_BENCHES if s.name in class_a]
if not specs:
    raise SystemExit("lipar-run-class-a: no Class A tier1 specs found")

merged = read_csv(out) if out.is_file() else []
for spec in specs:
    new_rows = run_benchmark(spec, runs=runs)
    merged = merge_rows(merged, new_rows, benchmark=spec.name)
write_csv(out, merged)
print(f"lipar-run-class-a: updated {out} ({', '.join(s.name for s in specs)})")
PY
