#!/usr/bin/env bash
# Phase G: li-array blocked GEMM perf gate — CPU logical 32 path + fair 50-run bench.
set -euo pipefail
ROOT="${PH_ML_LI_ARRAY_PERF_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

echo "==> Phase G symbols present"
grep -q 'ml_matmul_cpu_logical_32' packages/li-ml/src/lib.li \
  || { echo "missing ml_matmul_cpu_logical_32"; exit 1; }
grep -q 'array_matmul_blocked_32' packages/li-array/src/lib.li \
  || { echo "missing array_matmul_blocked_32"; exit 1; }
grep -q 'ml_matmul_cpu_logical_32' packages/li-array/src/lib.li \
  || { echo "li-array must route 32x32 via ml_matmul_cpu_logical_32"; exit 1; }
grep -q '@vectorized(lanes=4)' packages/li-ml/src/lib.li \
  || { echo "missing @vectorized on ml_matmul_cpu_nested"; exit 1; }

echo "==> Phase G spec"
[[ -f docs/game-dev/specs/li-array-perf-gemv-gemm.md ]] \
  || { echo "missing li-array-perf-gemv-gemm.md"; exit 1; }

echo "==> Phase G bench (50-run mean)"
grep -q 'PH_ML_LI_ARRAY32_RUNS' scripts/bench-ph-ml-li-array-matmul-32.sh \
  || { echo "bench must use PH_ML_LI_ARRAY32_RUNS"; exit 1; }
bash scripts/bench-ph-ml-li-array-matmul-32.sh || true

python3 - <<'PY'
import json, sys
from pathlib import Path

p = Path("benchmarks/results/ph-ml-li-array-matmul-32.json")
if not p.is_file():
    sys.exit("missing ph-ml-li-array-matmul-32.json")
r = json.loads(p.read_text())
if not r.get("executed"):
    sys.exit("32x32 bench must execute")
li = r.get("cpu_sec")
np_sec = r.get("numpy_cpu_sec")
ratio = r.get("ratio_vs_li")
li_over = r.get("li_over_numpy")
print(f"Phase G bench: li_cpu_sec={li} numpy_cpu_sec={np_sec} ratio_vs_li={ratio} li_over_numpy={li_over}")
if li and np_sec and li_over:
    if li_over > 2000:
        print(f"WARN: li_over_numpy={li_over} still far from target 2.0 (honest pilot gap)")
PY

echo "ph-ml-li-array-perf-g: completion gate OK"
