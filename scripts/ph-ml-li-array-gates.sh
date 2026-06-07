#!/usr/bin/env bash
# PH-ML li-array pilot gate — ArrayDesc smokes + run-only matmul bench.
set -euo pipefail
ROOT="${PH_ML_LI_ARRAY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_LI_ARRAY_ROOT='$wsl_root' PH_ML_LI_ARRAY_INNER=1 && bash scripts/ph-ml-li-array-gates.sh"
}

if [[ "${PH_ML_LI_ARRAY_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

echo "==> li-array package present"
[[ -d packages/li-array/src ]] || { echo "missing packages/li-array/src"; exit 1; }
grep -q 'li-array' packages/li.toml || { echo "li-array not in workspace members"; exit 1; }
grep -q 'array_broadcast_compatible' packages/li-array/src/lib.li \
  || { echo "missing array_broadcast_compatible"; exit 1; }
grep -q 'li_array_matmul_f32' packages/li-array/src/lib.li \
  || { echo "missing li_array_matmul_f32"; exit 1; }

for f in \
  packages/li-array/li-tests/smoke/builds.li \
  packages/li-array/li-tests/smoke/array_matmul_4.li \
  packages/li-array/li-tests/smoke/broadcast_reject_2_vs_4.li; do
  [[ -f "$f" ]] || { echo "missing smoke $f"; exit 1; }
done

[[ -f docs/game-dev/specs/li-array-rfc.md ]] \
  || { echo "missing li-array-rfc.md"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-li-array-competitive.md ]] \
  || { echo "missing ph-ml-li-array-competitive.md goal"; exit 1; }

echo "==> li-array matmul bench (run-only timing)"
bash scripts/bench-ph-ml-li-array-matmul.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

p = Path("benchmarks/results/ph-ml-li-array-matmul.json")
if not p.is_file():
    sys.exit("missing ph-ml-li-array-matmul.json")
r = json.loads(p.read_text())
if not r.get("executed"):
    sys.exit("li-array matmul bench must execute")
if r.get("validity_gate_pass") is not True:
    sys.exit("li-array matmul validity_gate_pass must be true")
if r.get("cpu_sec") is None:
    sys.exit("li-array matmul must record run-only cpu_sec")
if r.get("build_cpu_sec") is None:
    sys.exit("li-array matmul must record build_cpu_sec separately")
print("li-array gate: matmul bench OK cpu_sec=", r.get("cpu_sec"))
PY

echo "ph-ml-li-array: completion gate OK"
