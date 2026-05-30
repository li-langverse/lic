#!/usr/bin/env bash
# PH-ML Wave 3 completion/progress gates — WSL-aware on Windows hosts.
set -euo pipefail
ROOT="${PH_ML_WAVE3_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE3_ROOT='$wsl_root' PH_ML_WAVE3_INNER=1 LIC=./build-wsl/compiler/lic/lic CC=clang-22 CXX=clang++-22 && source scripts/ph-ml-wave3-gates.sh"
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
    packages/li-ml-rl/li-tests/smoke/job_graph_collect.li \
    packages/li-ml-rl/li-tests/smoke/env_pool_async_four.li \
    packages/li-studio/li-tests/smoke/studio_sim_rl_step.li; do
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    set +e
    "$lic" check "$smoke" 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic check failed: $smoke (exit $rc)"
      return 1
    fi
  done
}

if [[ "${PH_ML_WAVE3_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave3-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'JobGraph' docs/game-dev/specs/ml-async-parallel-rfc.md || { echo "RFC missing JobGraph"; exit 1; }
grep -q 'Wave 3' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 3"; exit 1; }
grep -q 'JobGraph' packages/li-ml-rl/src/lib.li || { echo "li-ml-rl missing JobGraph API"; exit 1; }

lic_check_smokes "$LIC" || exit 1

[[ -f benchmarks/results/ph-ml-async-env-collect.json ]] || { echo "missing benchmarks/results/ph-ml-async-env-collect.json"; exit 1; }
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-ml-async-env-collect.json")
d = json.loads(p.read_text())
n = d.get("env_count") or d.get("num_envs") or len(d.get("envs", []))
if n < 4:
    sys.exit(f"need >=4 envs, got {n}")
if not d.get("samples_collected", d.get("executed", True)):
    sys.exit("bench did not record sample collection")
PY

[[ -f docs/release-notes/2026-05-30-ph-ml-dl-rl-llm-wave3.md ]] || { echo "missing wave3 release note"; exit 1; }
grep -q 'Wave 3' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 3 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave3: completion gate OK"
