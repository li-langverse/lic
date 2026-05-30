#!/usr/bin/env bash
# PH-HW lig/LKIR sprint completion gate (native or WSL build-wsl).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

run_gate() {
  local lic="$1"
  test -x "$lic" || { echo "lic not executable: $lic"; return 1; }
  local missing=0
  while IFS= read -r path; do
    [[ -f "packages/lig/$path" ]] || { echo "missing LKIR: packages/lig/$path"; missing=1; }
  done < <(grep -E '^lkir = ' benchmarks/competitive/lig-kernels.toml | sed 's/.*"\(.*\)".*/\1/')
  test "$missing" -eq 0
  sed -i 's/\r$//' scripts/bench-lig-kernel-parity.sh 2>/dev/null || true
  LIC="$lic" ./scripts/bench-lig-kernel-parity.sh
  python3 - <<'PY'
import json, sys
from pathlib import Path
p = Path("benchmarks/results/lig-lkir-matmul.json")
d = json.loads(p.read_text())
if not d.get("compile_ok"):
    sys.exit("compile_ok false")
if not d.get("validity_gate_pass"):
    sys.exit("validity_gate_pass false")
if "cpu_sec" not in d and not any(
    k.get("executed")
    for k in d.get("kernels", [])
    if k.get("kernel_id") == d.get("kernel_id")
):
    sys.exit("bench did not record execution")
PY
  for smoke in packages/lig/li-tests/smoke/*.li; do
    "$lic" build --allow-open-vc "$smoke" -o /dev/null
  done
  echo "lig-lkir-ph-hw: completion gate OK"
}

LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
if [[ -x "$LIC" ]]; then
  run_gate "$LIC"
  exit 0
fi
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  run_gate "$ROOT/build-wsl/compiler/lic/lic"
  exit 0
fi
if command -v wsl >/dev/null 2>&1 && ! grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
  WSL_LIC="/mnt/c/Users/Julian/Documents/Programming/li/lic/build-wsl/compiler/lic/lic"
  wsl bash -lc "test -x '$WSL_LIC' || { echo 'WSL build missing — cmake -B build-wsl in WSL'; exit 1; }; cd /mnt/c/Users/Julian/Documents/Programming/li/lic && LIC='$WSL_LIC' bash scripts/lig-lkir-ph-hw-gate.sh"
  exit $?
fi
echo "build lic first: ./scripts/build.sh (or WSL build-wsl)"
exit 1
