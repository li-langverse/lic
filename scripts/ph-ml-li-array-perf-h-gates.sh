#!/usr/bin/env bash
# Phase H: li-array OpenBLAS hook gate — runtime BLAS + li-array dispatch + bench refresh.
set -euo pipefail
ROOT="${PH_ML_LI_ARRAY_PERF_H_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

echo "==> Phase A–G base gate"
bash scripts/ph-ml-li-array-gates.sh

echo "==> Phase G perf gate (blocked GEMM baseline)"
bash scripts/ph-ml-li-array-perf-gates.sh

echo "==> Phase H symbols present"
grep -q 'li_rt_blas_sgemm_ready' runtime/li_rt_blas.c \
  || { echo "missing li_rt_blas_sgemm_ready in runtime"; exit 1; }
grep -q 'ml_blas_matmul_f32' packages/li-ml/src/lib.li \
  || { echo "missing ml_blas_matmul_f32"; exit 1; }
grep -q 'li_array_matmul_blas_f32' packages/li-array/src/lib.li \
  || { echo "missing li_array_matmul_blas_f32"; exit 1; }
grep -q 'li_rt_blas_sgemm_f32' packages/li-ml/src/lib.li \
  || { echo "missing li_rt_blas_sgemm_f32 extern in li-ml"; exit 1; }

echo "==> Phase H spec"
[[ -f docs/game-dev/specs/li-array-perf-blas-hook.md ]] \
  || { echo "missing li-array-perf-blas-hook.md"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-li-array-perf-h.md ]] \
  || { echo "missing ph-ml-li-array-perf-h goal file"; exit 1; }

echo "==> Phase H bench (BLAS env optional)"
export LI_ARRAY_BLAS="${LI_ARRAY_BLAS:-openblas}"
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
target_met = r.get("ratio_target_met")
blas = r.get("blas_backend", "unknown")
print(
    f"Phase H bench: li_cpu_sec={li} numpy_cpu_sec={np_sec} "
    f"ratio_vs_li={ratio} li_over_numpy={li_over} "
    f"ratio_target_met={target_met} blas_backend={blas}"
)
if li_over and li_over > 2.0:
    print(f"WARN: li_over_numpy={li_over} still above target 2.0 (honest — Phase I/J continue)")
PY

echo "ph-ml-li-array-perf-h: completion gate OK"
