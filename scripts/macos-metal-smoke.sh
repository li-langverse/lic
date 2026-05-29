#!/usr/bin/env bash
# One-shot Mac M1+ verification for PH-HW Metal path.
set -euo pipefail
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macos-metal-smoke: requires Darwin (macOS)" >&2
  exit 1
fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export LIG_EMIT_METAL=1
unset CUDA_HOME CUDA_PATH
./scripts/build.sh
LIC="${LIC:-./build/compiler/lic/lic}"
echo "== lig_device_probe =="
"$LIC" check packages/lig/li-tests/smoke/lig_device_probe.li
echo "== metal timing probe =="
bash scripts/lig-metal-timing-probe.sh
echo "== kernel matmul parity (build + run) =="
OUT="$(mktemp /tmp/lig_matmul_smoke.XXXXXX)"
"$LIC" build --allow-open-vc packages/lig/li-tests/smoke/kernel_matmul_parity.li -o "$OUT"
"$OUT"
echo "exit=$?"
echo "== gpu test suite =="
./li-tests/run_all.sh gpu
echo "== bench JSON =="
LIG_EMIT_METAL=1 ./scripts/bench-lig-gpu-suite.sh
python3 -c "import json; r=json.load(open('benchmarks/results/lig-gpu-suite-honest.json')); print('gpu_timing_ns', r.get('gpu_timing_ns')); print('metal_timing_ns', r.get('metal_timing_ns', 'N/A'))"
