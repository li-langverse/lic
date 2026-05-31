#!/usr/bin/env bash
# PH-ML Wave 6 completion gates — WSL-aware on Windows hosts.
set -euo pipefail
ROOT="${PH_ML_WAVE6_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE6_ROOT='$wsl_root' PH_ML_WAVE6_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-wave6-gates.sh"
}

lic_bin_for_smokes() {
  local lic="$1"
  if [[ "$lic" == "$ROOT/build-wsl/compiler/lic/lic" ]] && [[ -x "./build-wsl/compiler/lic/lic" ]]; then
    echo "./build-wsl/compiler/lic/lic"
    return
  fi
  if [[ "$lic" == "$ROOT/build/compiler/lic/lic" ]] && [[ -x "./build/compiler/lic/lic" ]]; then
    echo "./build/compiler/lic/lic"
    return
  fi
  echo "$lic"
}

lic_check_smokes() {
  local lic smoke rc
  lic="$(lic_bin_for_smokes "$1")"
  export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
  for smoke in \
    packages/li-ml/li-tests/smoke/ml_matmul_general.li \
    packages/li-ml/li-tests/smoke/ml_matmul_16_flat.li \
    packages/li-ml-rl/li-tests/smoke/env_pool_thread_parallel.li \
    packages/li-ml-rl/li-tests/smoke/env_pool_process_scaffold.li \
    packages/li-ml-rl/li-tests/smoke/job_graph_sample_queue.li; do
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    set +e
    "$lic" build --allow-open-vc "$smoke" -o /dev/null 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic build failed: $smoke (exit $rc)"
      return 1
    fi
  done
}

if [[ "${PH_ML_WAVE6_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="./build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="./build/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
fi

[[ -x "$LIC" ]] || { echo "ph-ml-wave6-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 6' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 6"; exit 1; }
grep -q 'env_pool_stub_step_process_pool' packages/li-sim/src/lib.li || { echo "li-sim missing process pool scaffold"; exit 1; }
grep -q 'ml_matmul_flat_idx' packages/li-ml/src/lib.li || { echo "li-ml missing flat matmul idx"; exit 1; }
[[ -f benchmarks/competitive/ph-ml.toml ]] || { echo "missing ph-ml competitive registry"; exit 1; }

lic_check_smokes "$LIC" || exit 1

export LIC
bash scripts/bench-ph-ml-competitive.sh

[[ -f benchmarks/results/ph-ml-competitive.json ]] || { echo "missing ph-ml-competitive.json"; exit 1; }
[[ -f benchmarks/results/ph-ml-llm-forward.json ]] || { echo "missing ph-ml-llm-forward.json"; exit 1; }

python3 - <<'PY'
import json, os, sys
from pathlib import Path
import os

comp = json.loads(Path("benchmarks/results/ph-ml-competitive.json").read_text())
rows = comp.get("rows") or []
if len(rows) < 4:
    sys.exit("competitive JSON needs >=4 rows")
ids = {r.get("id") for r in rows}
need = {"matmul_lkir", "mlp_forward", "async_env_collect", "llm_forward"}
if not need.issubset(ids):
    sys.exit(f"missing competitive rows: {need - ids}")
for r in rows:
    if not r.get("competitors"):
        sys.exit(f"row {r.get('id')} missing competitors")
PY

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave6.md ]] || { echo "missing wave6 release note"; exit 1; }
grep -q 'Wave 6' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 6 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave6: completion gate OK"
