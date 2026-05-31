#!/usr/bin/env bash
# PH-ML Wave 9 completion gates — LLM recovery + C++/Rust competitors + RL process label.
set -euo pipefail
ROOT="${PH_ML_WAVE9_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE9_ROOT='$wsl_root' PH_ML_WAVE9_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-wave9-gates.sh"
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
    packages/li-llm/li-tests/smoke/llm_tokenize_bpe.li
    packages/li-llm/li-tests/smoke/llm_safetensors_header.li
    packages/li-llm/li-tests/smoke/llm_forward.li
    packages/li-llm/li-tests/smoke/llm_generate.li
    packages/li-llm/li-tests/smoke/llm_forward_matmul.li
    packages/li-ml/li-tests/smoke/ml_matmul_general.li
    packages/li-sim/li-tests/smoke/env_pool_process_mode_label.li
  )
  i=0
  for smoke in "${smokes[@]}"; do
    i=$((i + 1))
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    set +e
    "$lic" build --allow-open-vc "$smoke" -o "/tmp/ph-ml-wave9-smoke-${i}.out" 2>&1
    rc=$?
    set -e
    if [[ "$rc" -ne 0 ]]; then
      echo "lic build failed: $smoke (exit $rc)"
      return 1
    fi
  done
}

if [[ "${PH_ML_WAVE9_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave9-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 9' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 9"; exit 1; }
grep -q 'llm_safetensors_parse_header' packages/li-llm/src/lib.li || { echo "li-llm missing safetensors header parse"; exit 1; }
grep -q 'llm_forward_matmul_cpu_hint' packages/li-llm/src/lib.li || { echo "li-llm missing transformer scaffold"; exit 1; }
grep -q 'sim_rl_env_worker_process_mode_label' packages/li-sim/src/lib.li || { echo "li-sim missing process mode label"; exit 1; }
[[ -f scripts/bench_ph_ml_competitor_cpp_openmp_matmul.py ]] || { echo "missing cpp competitor driver"; exit 1; }
[[ -f packages/li-llm/fixtures/vocab.bpe.json ]] || { echo "missing vocab.bpe.json fixture"; exit 1; }

lic_check_smokes "$LIC" || exit 1

python3 -m pip install --user --break-system-packages \
  -r scripts/requirements-ph-ml-competitive.txt >/dev/null 2>&1 || true

export LIC CC CXX
bash scripts/bench-ph-ml-competitive.sh

[[ -f "$BENCHMARKS_RESULTS/ph-ml-competitive.json" ]] || { echo "missing ph-ml-competitive.json"; exit 1; }
[[ -f "$BENCHMARKS_RESULTS/ph-ml-llm-forward.json" ]] || { echo "missing ph-ml-llm-forward.json"; exit 1; }

python3 - <<'PY'
import json, os, sys
from pathlib import Path

results = Path(os.environ["BENCHMARKS_RESULTS"])
llm = json.loads((results / "ph-ml-llm-forward.json").read_text())
if not llm.get("validity_gate_pass"):
    sys.exit("ph-ml-llm-forward validity_gate_pass must be true")
comp = json.loads((results / "ph-ml-competitive.json").read_text())
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
matmul = rows.get("matmul_lkir") or {}
comps = {c.get("id"): c for c in (matmul.get("competitors") or [])}
executed_count = sum(1 for c in comps.values() if c.get("executed"))
if executed_count < 4:
    sys.exit(f"need >=4 executed matmul competitors, got {executed_count}")
for required in ("pytorch_cpu", "jax_cpu", "python_numpy"):
    row = comps.get(required)
    if not row or not row.get("executed"):
        sys.exit(f"{required} competitor must have executed:true")
wave9_new = ("cpp_openmp", "rust_ndarray_rayon")
wave9_ok = sum(1 for cid in wave9_new if (comps.get(cid) or {}).get("executed"))
if wave9_ok < 1:
    sys.exit("at least one Wave 9 competitor (cpp_openmp or rust_ndarray_rayon) must execute")
llm_row = rows.get("llm_forward") or {}
li_llm = llm_row.get("li") or {}
if not li_llm.get("validity_gate_pass"):
    sys.exit("llm_forward competitive row li.validity_gate_pass must be true")
PY

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave9.md ]] || { echo "missing wave9 release note"; exit 1; }
grep -q 'Wave 9' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 9 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave9: completion gate OK"
