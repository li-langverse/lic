#!/usr/bin/env bash
# PH-ML Wave 4 completion/progress gates ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Â WSL-aware on Windows hosts.
set -euo pipefail
ROOT="${PH_ML_WAVE4_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE4_ROOT='$wsl_root' PH_ML_WAVE4_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-wave4-gates.sh"
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
    packages/li-ml/li-tests/smoke/ml_mlp_forward.li \
    packages/li-ml/li-tests/smoke/ml_lig_matmul_run_auto.li \
    packages/li-ml-rl/li-tests/smoke/job_graph_collect.li \
    packages/li-ml-rl/li-tests/smoke/job_graph_train_eval.li \
    packages/li-ml-rl/li-tests/smoke/env_pool_persistent.li \
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

if [[ "${PH_ML_WAVE4_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave4-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 4' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 4"; exit 1; }
grep -q 'ml_lig_matmul_run_auto' packages/li-ml/src/lib.li || { echo "li-ml missing ml_lig_matmul_run_auto"; exit 1; }
grep -q 'TrainStepJob' packages/li-ml-rl/src/lib.li || { echo "li-ml-rl missing TrainStepJob"; exit 1; }
grep -q 'sim_session_env_pool_init' packages/li-ml-rl/src/lib.li || { echo "li-ml-rl missing persistent pool collect"; exit 1; }

lic_check_smokes "$LIC" || exit 1

bash scripts/bench-ph-ml-async-env-collect.sh
bash scripts/bench-ph-ml-mlp-forward.sh

[[ -f "$BENCHMARKS_RESULTS/ph-ml-async-env-collect.json ]] || { echo "missing ph-ml-async-env-collect.json"; exit 1; }
[[ -f "$BENCHMARKS_RESULTS/ph-ml-mlp-forward.json ]] || { echo "missing ph-ml-mlp-forward.json"; exit 1; }

python3 - <<'PY'
import json, os, sys
from pathlib import Path
import os

async_p = Path(os.environ["BENCHMARKS_RESULTS"] + "/" + "ph-ml-async-env-collect.json")
async_d = json.loads(async_p.read_text())
if async_d.get("worker") == "stub":
    sys.exit('async bench must not label worker "stub"')
if async_d.get("worker") != "sync":
    sys.exit("async bench worker must be sync")
if (async_d.get("env_count") or 0) < 4:
    sys.exit("need >=4 envs")

mlp_p = Path(os.environ["BENCHMARKS_RESULTS"] + "/" + "ph-ml-mlp-forward.json")
mlp_d = json.loads(mlp_p.read_text())
if not mlp_d.get("executed"):
    sys.exit("mlp bench must record executed: true")
if not mlp_d.get("validity_gate_pass"):
    sys.exit("mlp bench validity_gate_pass false")
PY

[[ -f docs/release-notes/2026-05-30-ph-ml-dl-rl-llm-wave4.md ]] || { echo "missing wave4 release note"; exit 1; }
grep -q 'Wave 4' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 4 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave4: completion gate OK"