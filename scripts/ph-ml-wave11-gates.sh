#!/usr/bin/env bash
# PH-ML Wave 11 carryover gates — deferred Wave 10 items.
set -euo pipefail
ROOT="${PH_ML_WAVE11_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE11_ROOT='$wsl_root' PH_ML_WAVE11_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-wave11-gates.sh"
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
  local lic smoke rc i
  lic="$(lic_bin_for_smokes "$1")"
  export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
  local smokes=(
    packages/li-llm/li-tests/smoke/llm_safetensors_bytes.li
    packages/li-llm/li-tests/smoke/llm_matmul_bridge.li
    packages/li-llm/li-tests/smoke/llm_trusted_backend_scaffold.li
    packages/li-ml/li-tests/smoke/ml_gpu_matmul_stub.li
    packages/li-ml/li-tests/smoke/ml_matmul_16_lkir.li
    packages/li-sim/li-tests/smoke/env_pool_ipc_fork.li
  )
  i=0
  for smoke in "${smokes[@]}"; do
    i=$((i + 1))
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    set +e
    "$lic" build --allow-open-vc "$smoke" -o "/tmp/ph-ml-wave11-smoke-${i}.out" 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic build failed: $smoke (exit $rc)"
      return 1
    fi
  done
}

if [[ "${PH_ML_WAVE11_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave11-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 11' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 11"; exit 1; }
grep -q 'llm_safetensors_tensor_bytes_scaffold' packages/li-llm/src/lib.li || { echo "li-llm missing byte tensor scaffold"; exit 1; }
grep -q 'ml_matmul_lkir_logical_16' packages/li-ml/src/lib.li || { echo "li-ml missing 16x16 LKIR logical matmul"; exit 1; }
grep -q 'sim_rl_env_ipc_fork_mode_label' packages/li-sim/src/lib.li || { echo "li-sim missing fork IPC label"; exit 1; }
[[ -f scripts/ph-ml-wave10-gates.sh ]] || { echo "missing wave10 gates (baseline)"; exit 1; }

lic_check_smokes "$LIC" || exit 1

bash scripts/lillm-import.sh test/model fixtures/imported-wave11-smoke 2>/dev/null || LILLM_IMPORT_OFFLINE=1 bash scripts/lillm-import.sh test/model fixtures/imported-wave11-smoke

python3 -m pip install --user --break-system-packages \
  -r scripts/requirements-ph-ml-competitive.txt >/dev/null 2>&1 || true

export LIC CC CXX
bash scripts/ph-ml-wave10-gates.sh

export PH_ML_MATMUL_N=16
bash scripts/bench-ph-ml-lkir-matmul-16.sh || true
export PH_ML_RUST_MLP_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-rust-mlp.json"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
python3 scripts/bench_ph_ml_competitor_rust_mlp.py || true
export PH_ML_RL_IPC_FORK_OUT="$BENCHMARKS_RESULTS/ph-ml-rl-env-ipc-fork.json"
python3 scripts/bench_ph_ml_rl_env_ipc_fork.py || true

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave11.md ]] || { echo "missing wave11 release note"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-dl-rl-llm-wave11.md ]] || { echo "missing wave11 sprint doc"; exit 1; }
grep -q 'Wave 11' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 11"; exit 1; }
echo "ph-ml-dl-rl-llm-wave11: completion gate OK"
