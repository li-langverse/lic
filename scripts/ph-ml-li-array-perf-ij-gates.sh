#!/usr/bin/env bash
# Phase I/J: li-array dense 32×32 buffer + tile sweep + competitive bench refresh.
set -euo pipefail
ROOT="${PH_ML_LI_ARRAY_PERF_IJ_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

echo "==> Phase H base gate (prior sprint)"
bash scripts/ph-ml-li-array-perf-h-gates.sh

echo "==> Phase I symbols present"
grep -q 'ml_matmul_pilot_to_dense_32' packages/li-ml/src/lib.li \
  || { echo "missing ml_matmul_pilot_to_dense_32"; exit 1; }
grep -q 'ml_blas_matmul_dense32_identity' packages/li-ml/src/lib.li \
  || { echo "missing ml_blas_matmul_dense32_identity"; exit 1; }
grep -q 'ml_matmul_cpu_nested_16' packages/li-ml/src/lib.li \
  || { echo "missing ml_matmul_cpu_nested_16"; exit 1; }
grep -q 'ml_matmul_cpu_dense_blocked' packages/li-ml/src/lib.li \
  || { echo "missing ml_matmul_cpu_dense_blocked"; exit 1; }
grep -q 'li_rt_gemm_tile_env' runtime/li_rt_blas.c \
  || { echo "missing li_rt_gemm_tile_env in runtime"; exit 1; }
grep -q 'li_rt_blas_matmul_dense32_identity' runtime/li_rt_blas.c \
  || { echo "missing li_rt_blas_matmul_dense32_identity in runtime"; exit 1; }
grep -q 'ml_matmul_gemm_tile_env' packages/li-ml/src/lib.li \
  || { echo "missing ml_matmul_gemm_tile_env"; exit 1; }
[[ -f scripts/bench-ph-ml-li-array-gemm-tile-sweep.sh ]] \
  || { echo "missing bench-ph-ml-li-array-gemm-tile-sweep.sh"; exit 1; }

echo "==> Phase I goal file"
[[ -f data/goal-directed-sprints/ph-ml-li-array-perf-ij.md ]] \
  || { echo "missing ph-ml-li-array-perf-ij goal file"; exit 1; }

echo "==> Phase I tile sweep (optional bench)"
bash scripts/bench-ph-ml-li-array-gemm-tile-sweep.sh || true

echo "==> Phase J bench (50-run mean, metadata)"
export LI_ARRAY_BLAS="${LI_ARRAY_BLAS:-openblas}"
export LI_ARRAY_GEMM_TILE="${LI_ARRAY_GEMM_TILE:-8}"
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
required_meta = ("blas_backend", "workload_class", "buffer_class", "gemm_tile")
missing = [k for k in required_meta if k not in r]
if missing:
    sys.exit(f"Phase J bench missing metadata: {missing}")
li = r.get("cpu_sec")
np_sec = r.get("numpy_cpu_sec")
li_over = r.get("li_over_numpy")
target_met = r.get("ratio_target_met")
blas = r.get("blas_backend")
buf = r.get("buffer_class")
tile = r.get("gemm_tile")
baseline = r.get("phase_h_baseline_li_over_numpy")
print(
    f"Phase I/J bench: li_cpu_sec={li} numpy_cpu_sec={np_sec} "
    f"li_over_numpy={li_over} ratio_target_met={target_met} "
    f"blas_backend={blas} buffer_class={buf} gemm_tile={tile} "
    f"phase_h_baseline={baseline}"
)
if li_over and baseline and li_over >= baseline:
    print(f"WARN: li_over_numpy={li_over} not improved vs Phase H baseline {baseline}")
if li_over and li_over > 2.0:
    print(f"WARN: li_over_numpy={li_over} still above target 2.0 (honest — continue tuning)")
PY

echo "ph-ml-li-array-perf-ij: completion gate OK"
