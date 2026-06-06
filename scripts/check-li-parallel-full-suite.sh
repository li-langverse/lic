#!/usr/bin/env bash
# WP-PAR-47 — li-parallel full-suite completion gate (PR profile, dual-mode).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SUITE="$ROOT/packages/li-parallel/scripts/lipar-suite.sh"
CSV="${BENCHMARKS_CSV:-$(cd "$ROOT/../benchmarks" 2>/dev/null && pwd)/results/latest.csv}"

if [[ ! -f "$SUITE" ]]; then
  echo "ERROR: missing $SUITE" >&2
  exit 1
fi

echo "==> li-parallel gate: lipar-suite --dual-mode --profile pr"
bash "$SUITE" --dual-mode --profile pr --cores "${LIPAR_CORES:-8}"

if [[ ! -f "$CSV" ]]; then
  echo "ERROR: benchmark CSV missing at $CSV" >&2
  exit 1
fi

python3 - "$CSV" <<'PY'
import csv
import sys

path = sys.argv[1]
required = ("matmul_blocked", "reduce_sum", "simd_dot", "num_dot_axpy")
rows = list(csv.DictReader(open(path, newline="", encoding="utf-8")))
by = {}
for r in rows:
    if r.get("metric") != "wall_time":
        continue
    key = (r.get("benchmark"), r.get("lang"))
    by[key] = r

missing = []
for bid in required:
    for lang in ("li_serial", "li_parallel"):
        if (bid, lang) not in by:
            missing.append(f"{bid}/{lang}")

if missing:
    print("GATE: dual-mode rows missing:", ", ".join(missing), file=sys.stderr)
    sys.exit(1)

print("GATE: dual-mode Class A tier1 rows present for", ", ".join(required))
PY

echo "==> check-li-parallel-full-suite.sh: PASS"
