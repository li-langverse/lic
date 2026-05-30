#!/usr/bin/env bash
# PH-ML Wave 2 completion/progress gates — WSL-aware on Windows hosts.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "set -euo pipefail; cd '$wsl_root'; export LIC=./build-wsl/compiler/lic/lic CC=clang-22 CXX=clang++-22; PH_ML_WAVE2_INNER=1 bash scripts/ph-ml-wave2-gates.sh"
}

lic_check_smokes() {
  local lic="$1"
  export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
  for smoke in \
    packages/li-ml/li-tests/smoke/ml_matmul_lkir_parity.li \
    packages/li-ml/li-tests/smoke/ml_gpu_matmul_stub.li; do
    [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; return 1; }
    "$lic" build --allow-open-vc "$smoke" -o /dev/null || return 1
  done
}

if [[ "${PH_ML_WAVE2_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  if wsl.exe bash -lc "test -x \"\$(wslpath -u '$ROOT')/build-wsl/compiler/lic/lic\"" 2>/dev/null; then
    run_in_wsl
    exit 0
  fi
fi

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
fi

[[ -x "$LIC" ]] || { echo "ph-ml-wave2-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

lic_check_smokes "$LIC"

[[ -f benchmarks/results/ph-ml-lkir-matmul.json ]] || { echo "missing benchmarks/results/ph-ml-lkir-matmul.json"; exit 1; }
python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/ph-ml-lkir-matmul.json")
d = json.loads(p.read_text())
if not d.get("compile_ok"):
    sys.exit("compile_ok false")
if not d.get("validity_gate_pass"):
    sys.exit("validity_gate_pass false")
if "cpu_sec" not in d and not any(k.get("executed") for k in d.get("kernels", [])):
    sys.exit("bench did not record execution")
PY

[[ -f docs/release-notes/2026-05-30-ph-ml-dl-rl-llm-wave2.md ]] || { echo "missing wave2 release note"; exit 1; }
grep -q 'Wave 2' docs/game-dev/PH-ML-GPU-execution-tracker.md || { echo "tracker missing Wave 2 rows"; exit 1; }
echo "ph-ml-dl-rl-llm-wave2: completion gate OK"