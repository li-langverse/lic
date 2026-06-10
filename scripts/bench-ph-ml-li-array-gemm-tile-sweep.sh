#!/usr/bin/env bash
# Phase I: sweep LI_ARRAY_GEMM_TILE (8 vs 16) for dense 32×32 blocked CPU path.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/benchmarks/results/ph-ml-li-array-gemm-tile-sweep.json"
BENCH="$ROOT/benchmarks/results/ph-ml-li-array-matmul-32.json"
mkdir -p "$ROOT/benchmarks/results"

echo "==> Phase I tile sweep (CPU dense blocked, BLAS off)"
export LI_ARRAY_BLAS=0
rows_json="["
first=1
for tile in 8 16; do
  export LI_ARRAY_GEMM_TILE="$tile"
  bash "$ROOT/scripts/bench-ph-ml-li-array-matmul-32.sh" >/dev/null 2>&1 || true
  cp -f "$BENCH" "$ROOT/benchmarks/results/ph-ml-li-array-matmul-32-tile${tile}.json" 2>/dev/null || true
  row="$(python3 - <<PY
import json
from pathlib import Path
p = Path("$BENCH")
if not p.is_file():
    print(json.dumps({"gemm_tile": $tile, "executed": False}))
else:
    r = json.loads(p.read_text())
    print(json.dumps({
        "gemm_tile": $tile,
        "executed": r.get("executed", False),
        "cpu_sec": r.get("cpu_sec"),
        "li_over_numpy": r.get("li_over_numpy"),
        "ratio_vs_li": r.get("ratio_vs_li"),
        "buffer_class": r.get("buffer_class"),
    }))
PY
)"
  if [[ "$first" == "1" ]]; then
    first=0
  else
    rows_json+=","
  fi
  rows_json+="$row"
  echo "tile $tile: $(echo "$row" | python3 -c 'import json,sys; r=json.load(sys.stdin); print("li_over_numpy=%s cpu_sec=%s" % (r.get("li_over_numpy"), r.get("cpu_sec")))')"
done
rows_json+="]"

python3 - <<PY
import json
rows = json.loads('''$rows_json''')
report = {"suite": "ph-ml-li-array-gemm-tile-sweep", "tiles": rows}
Path = __import__("pathlib").Path
out = Path("$OUT")
out.write_text(json.dumps(report, indent=2) + "\n")
print(f"tile-sweep: wrote {out}")
PY

echo "bench-ph-ml-li-array-gemm-tile-sweep: done"
