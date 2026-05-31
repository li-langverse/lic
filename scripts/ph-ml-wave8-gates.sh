#!/usr/bin/env bash
# PH-ML Wave 8 completion gates — SOTA competitor drivers (PyTorch + JAX required on matmul).
set -euo pipefail
ROOT="${PH_ML_WAVE8_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_WAVE8_ROOT='$wsl_root' PH_ML_WAVE8_INNER=1 LIC=./build-wsl/compiler/lic/lic source scripts/ph-ml-wave8-gates.sh"
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
    packages/li-ml/li-tests/smoke/ml_matmul_lkir_parity.li \
    packages/li-ml/li-tests/smoke/ml_mlp_forward.li; do
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

if [[ "${PH_ML_WAVE8_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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

[[ -x "$LIC" ]] || { echo "ph-ml-wave8-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

grep -q 'Wave 8' docs/game-dev/PH-ML-GPU-battle-plan.md || { echo "battle plan missing Wave 8"; exit 1; }
[[ -f scripts/bench-ph-ml-competitor-all.sh ]] || { echo "missing competitor-all driver"; exit 1; }
[[ -f scripts/requirements-ph-ml-competitive.txt ]] || { echo "missing requirements-ph-ml-competitive.txt"; exit 1; }

lic_check_smokes "$LIC" || exit 1

python3 -m pip install --user --break-system-packages \
  -r scripts/requirements-ph-ml-competitive.txt >/dev/null 2>&1 || true

export LIC CC CXX
bash scripts/bench-ph-ml-competitive.sh

[[ -f "$BENCHMARKS_RESULTS/ph-ml-competitive.json" ]] || { echo "missing ph-ml-competitive.json"; exit 1; }

python3 - <<'PY'
import json, os, sys
from pathlib import Path

comp = json.loads(Path(os.environ["BENCHMARKS_RESULTS"], "ph-ml-competitive.json").read_text())
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
matmul = rows.get("matmul_lkir") or {}
li = matmul.get("li") or {}
if not li.get("validity_gate_pass"):
    sys.exit("matmul_lkir Li row must pass validity_gate_pass (LKIR smoke)")
comps = {c.get("id"): c for c in (matmul.get("competitors") or [])}
for required in ("pytorch_cpu", "jax_cpu"):
    row = comps.get(required)
    if not row or not row.get("executed"):
        sys.exit(f"{required} competitor must have executed:true for matmul_lkir")
    if row.get("cpu_sec") is None:
        sys.exit(f"{required} competitor missing cpu_sec")
    if row.get("ratio_vs_li") is None:
        sys.exit(f"{required} competitor missing ratio_vs_li")
mlp = rows.get("mlp_forward") or {}
py_mlp = next((c for c in (mlp.get("competitors") or []) if c.get("id") == "pytorch_cpu"), None)
if not py_mlp or not py_mlp.get("executed"):
    sys.exit("pytorch_cpu MLP competitor must have executed:true")
PY

[[ -f docs/release-notes/2026-05-31-ph-ml-dl-rl-llm-wave8.md ]] || { echo "missing wave8 release note"; exit 1; }
grep -q 'Wave 8' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 8 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave8: completion gate OK"
