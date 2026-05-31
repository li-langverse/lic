#!/usr/bin/env bash
# PH-ML Wave 5 completion/progress gates — WSL-aware on Windows hosts.
set -euo pipefail
ROOT="${PH_ML_WAVE5_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE5_ROOT='$wsl_root' PH_ML_WAVE5_INNER=1 LIC=./build-wsl/compiler/lic/lic; source scripts/ph-ml-wave5-gates.sh"
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
    packages/li-ml-rl/li-tests/smoke/env_pool_thread_parallel.li \
    packages/li-ml-rl/li-tests/smoke/job_graph_sample_queue.li \
    packages/li-ml-rl/li-tests/smoke/job_graph_async_timing.li \
    packages/li-ml-rl/li-tests/smoke/job_graph_collect.li \
    packages/li-ml-rl/li-tests/smoke/env_pool_async_four.li; do
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

if [[ "${PH_ML_WAVE5_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave5-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 5' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 5"; exit 1; }
grep -q 'env_pool_fill_rewards_parallel' packages/li-sim/src/lib.li || { echo "li-sim missing parallel env fill"; exit 1; }
grep -q 'sample_queue_len' packages/li-ml-rl/src/lib.li || { echo "li-ml-rl missing sample queue"; exit 1; }
grep -q 'ml_matmul_cpu_ref' packages/li-ml/src/lib.li || { echo "li-ml missing general flat matmul"; exit 1; }

lic_check_smokes "$LIC" || exit 1

export LIC
bash scripts/bench-ph-ml-async-env-collect.sh
bash scripts/bench-ph-ml-mlp-forward.sh
if [[ -f scripts/bench-ph-ml-competitive.sh ]]; then bash scripts/bench-ph-ml-competitive.sh; fi

[[ -f benchmarks/results/ph-ml-async-env-collect.json ]] || { echo "missing ph-ml-async-env-collect.json"; exit 1; }

python3 - <<'PY'
import json, sys
from pathlib import Path

async_p = Path("benchmarks/results/ph-ml-async-env-collect.json")
async_d = json.loads(async_p.read_text())
if async_d.get("worker") != "thread_pool":
    sys.exit("async bench worker must be thread_pool")
if not async_d.get("g_ml_async_proof"):
    sys.exit("async bench must record g_ml_async_proof")
if (async_d.get("env_count") or 0) < 4:
    sys.exit("need >=4 envs")
PY

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave5.md ]] || { echo "missing wave5 release note"; exit 1; }
grep -q 'Wave 5' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 5 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave5: completion gate OK"
