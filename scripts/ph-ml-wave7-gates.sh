#!/usr/bin/env bash
# PH-ML Wave 7 completion gates — WSL-aware on Windows hosts.
set -euo pipefail
ROOT="${PH_ML_WAVE7_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '

')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE7_ROOT='$wsl_root' PH_ML_WAVE7_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-wave7-gates.sh"
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
  for smoke in     packages/li-llm/li-tests/smoke/llm_tokenize_roundtrip.li     packages/li-llm/li-tests/smoke/llm_tokenize_bpe.li     packages/li-llm/li-tests/smoke/llm_safetensors_header.li     packages/li-llm/li-tests/smoke/llm_load_weights.li     packages/li-llm/li-tests/smoke/llm_forward.li     packages/li-llm/li-tests/smoke/llm_generate.li     packages/li-llm/li-tests/smoke/llm_forward_matmul.li     packages/li-ml/li-tests/smoke/ml_matmul_general.li; do
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

if [[ "${PH_ML_WAVE7_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '

')"
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave7-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 7' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 7"; exit 1; }
grep -q 'llm_safetensors_parse_header' packages/li-llm/src/lib.li || { echo "li-llm missing safetensors header parse"; exit 1; }
grep -q 'llm_transformer_matmul_contrib' packages/li-llm/src/lib.li || { echo "li-llm missing transformer scaffold"; exit 1; }
grep -q 'sim_rl_env_worker_process_mode_label' packages/li-sim/src/lib.li || { echo "li-sim missing process mode label"; exit 1; }
[[ -f scripts/bench-ph-ml-competitor-numpy-matmul.sh ]] || { echo "missing numpy competitor driver"; exit 1; }

lic_check_smokes "$LIC" || exit 1

python3 -m pip install --user --break-system-packages "numpy==2.2.6" >/dev/null 2>&1 || true

export LIC CC CXX
bash scripts/bench-ph-ml-competitive.sh

[[ -f "$BENCHMARKS_RESULTS/ph-ml-competitive.json" ]] || { echo "missing ph-ml-competitive.json"; exit 1; }
[[ -f "$BENCHMARKS_RESULTS/ph-ml-llm-forward.json" ]] || { echo "missing ph-ml-llm-forward.json"; exit 1; }

python3 - <<'PY'
import json, os, sys
from pathlib import Path
comp = json.loads(Path(os.environ["BENCHMARKS_RESULTS"], "ph-ml-competitive.json").read_text())
llm = json.loads(Path(os.environ["BENCHMARKS_RESULTS"], "ph-ml-llm-forward.json").read_text())
if not llm.get("validity_gate_pass"):
    sys.exit("ph-ml-llm-forward validity_gate_pass must be true")
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
matmul = rows.get("matmul_lkir") or {}
numpy_row = next((c for c in (matmul.get("competitors") or []) if c.get("id") == "python_numpy"), None)
if not numpy_row or not numpy_row.get("executed"):
    sys.exit("python_numpy competitor must have executed:true for matmul_lkir")
if numpy_row.get("cpu_sec") is None:
    sys.exit("python_numpy competitor missing cpu_sec")
PY

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave7.md ]] || { echo "missing wave7 release note"; exit 1; }
grep -q 'Wave 7' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 7 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave7: completion gate OK"
