#!/usr/bin/env bash
# PH-ML Wave 12 final deferred gates — runs Wave 11 baseline + Wave 12 smokes.
set -euo pipefail
ROOT="${PH_ML_WAVE12_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"
export LIG_EMIT_CUDA=1

is_wsl() {
  [[ -n "${WSL_INTEROP:-}" || -n "${WSL_DISTRO_NAME:-}" ]] && return 0
  [[ -r /proc/version ]] && grep -qi microsoft /proc/version && return 0
  return 1
}

_wsl_path_u() {
  wsl.exe wslpath -u "$1" 2>/dev/null | tr -d '\r\n'
}

run_in_wsl() {
  local wsl_root wsl_bench
  wsl_root="$(_wsl_path_u "$ROOT")"
  wsl_bench=""
  if [[ -n "${BENCHMARKS_ROOT:-}" ]]; then
    wsl_bench="$(_wsl_path_u "$BENCHMARKS_ROOT")" || wsl_bench=""
  fi
  if [[ -z "$wsl_bench" ]]; then
    for _c in "$ROOT/../benchmarks" "$ROOT/../../benchmarks" "$ROOT/../../../../../benchmarks"; do
      if [[ -f "$_c/harness/bench.py" ]]; then
        wsl_bench="$(_wsl_path_u "$(cd "$_c" && pwd)")" || wsl_bench=""
        break
      fi
    done
  fi
  wsl.exe bash -lc "cd '$wsl_root' && PH_ML_WAVE12_ROOT='$wsl_root' PH_ML_WAVE12_INNER=1 LIG_EMIT_CUDA=1 BENCHMARKS_ROOT='${wsl_bench}' LIC=./build-wsl/compiler/lic/lic bash scripts/ph-ml-wave12-gates.sh"
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
  export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}" LIG_EMIT_CUDA=1
  local smokes=(
    packages/li-ml/li-tests/smoke/ml_gpu_lkir_launch.li
    packages/li-llm/li-tests/smoke/llm_safetensors_mmap.li
    packages/li-llm/li-tests/smoke/llm_trusted_httpd_route.li
  )
  i=0
  for smoke in "${smokes[@]}"; do
    i=$((i + 1))
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    set +e
    "$lic" build --allow-open-vc "$smoke" -o "/tmp/ph-ml-wave12-smoke-${i}.out" 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic build failed: $smoke (exit $rc)"
      return 1
    fi
  done
}

if [[ "${PH_ML_WAVE12_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(_wsl_path_u "$ROOT")"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

LIC="${LIC:-}"
if is_wsl && [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="./build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="./build/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
fi

[[ -x "$LIC" ]] || { echo "ph-ml-wave12-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 12' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 12"; exit 1; }
grep -q 'ml_gpu_lkir_launch_pipeline' packages/li-ml/src/lib.li || { echo "li-ml missing launch pipeline"; exit 1; }
grep -q 'llm_safetensors_tensor_bytes_mmap' packages/li-llm/src/lib.li || { echo "li-llm missing mmap loader"; exit 1; }
grep -q 'lig_emit_vendor_progress' packages/lig/src/lib.li || { echo "lig missing emit progress"; exit 1; }
grep -q 'sim_rl_env_ipc_fork_os_ready' packages/li-sim/src/lib.li || { echo "li-sim missing fork os ready"; exit 1; }

lic_check_smokes "$LIC" || exit 1

bash scripts/lig-emit-vendor-stub.sh
export LIC CC CXX LIG_EMIT_CUDA
bash scripts/ph-ml-wave11-gates.sh

python3 -m pip install --user --break-system-packages   -r scripts/requirements-ph-ml-competitive.txt   -r scripts/requirements-ph-ml-wave12-rl.txt >/dev/null 2>&1 || true

export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"
export PH_ML_RL_IPC_FORK_OUT="$BENCHMARKS_RESULTS/ph-ml-rl-env-ipc-fork.json"
python3 scripts/bench_ph_ml_rl_env_ipc_fork.py
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-ml-rl-env-ipc-fork.json")
d = json.loads(p.read_text())
if not d.get("executed"):
    sys.exit("fork/spawn IPC bench must execute")
PY

export PH_ML_SB3_VECENV_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-sb3-vecenv.json"
python3 scripts/bench_ph_ml_competitor_sb3_vecenv.py
export PH_ML_GATE_COMPETITOR_CHECK=sb3
python3 scripts/lib/ph_ml_gate_competitor_honesty.py

export PH_ML_TENSORFLOW_CPU_MATMUL_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-tensorflow-cpu-matmul.json"
python3 scripts/bench_ph_ml_competitor_tensorflow_cpu_matmul.py || true
export PH_ML_TRITON_MATMUL_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-triton-matmul.json"
python3 scripts/bench_ph_ml_competitor_triton_matmul.py || true
# Triton: executed:true only when CUDA present; CI CPU-only is OK (note documents skip).

export PH_ML_RUST_MLP_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-rust-mlp.json"
python3 scripts/bench_ph_ml_competitor_rust_mlp.py || true
export PH_ML_RAY_RLLIB_OUT="$BENCHMARKS_RESULTS/ph-ml-competitor-ray-rllib.json"
python3 scripts/bench_ph_ml_competitor_ray_rllib.py || true
export PH_ML_LLM_TRUSTED_HTTPD_OUT="$BENCHMARKS_RESULTS/ph-ml-llm-trusted-httpd.json"
python3 scripts/bench_ph_ml_llm_trusted_httpd.py

export PH_ML_MATMUL_N=16
bash scripts/bench-ph-ml-lkir-matmul-16.sh || true

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave12.md ]] || { echo "missing wave12 release note"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-dl-rl-llm-wave12.md ]] || { echo "missing wave12 sprint doc"; exit 1; }
grep -q 'Wave 12' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 12"; exit 1; }
echo "ph-ml-dl-rl-llm-wave12: completion gate OK"
