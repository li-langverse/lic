#!/usr/bin/env bash
# One-shot NVIDIA Linux lab verification (CUDA path).
set -euo pipefail
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "linux-gpu-smoke: intended for Linux NVIDIA lab" >&2
fi
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
for candidate in /usr/lib/cuda /usr/local/cuda /opt/cuda; do
  if [[ -x "${candidate}/bin/nvcc" ]]; then
    export CUDA_HOME="$candidate"
    break
  fi
done
export PATH="${CUDA_HOME:-/usr/lib/cuda}/bin:${PATH}"
export LIG_EMIT_CUDA=1
unset LIG_EMIT_METAL
./scripts/build.sh
echo "== cuda-home-probe =="
bash scripts/cuda-home-probe.sh
echo "== cuda timing =="
bash scripts/lig-cuda-timing-probe.sh
LIC="${LIC:-./build/compiler/lic/lic}"
OUT="$(mktemp /tmp/lig_matmul_smoke.XXXXXX)"
echo "== kernel matmul parity =="
"$LIC" build --allow-open-vc packages/lig/li-tests/smoke/kernel_matmul_parity.li -o "$OUT"
"$OUT"
echo "exit=$?"
echo "== lkir validate =="
bash scripts/lkir-validate.sh
echo "== gpu tests =="
./li-tests/run_all.sh gpu
echo "== bench suite =="
LIG_EMIT_CUDA=1 ./scripts/bench-lig-gpu-suite.sh
python3 -c "import json; r=json.load(open('benchmarks/results/lig-gpu-suite-honest.json')); print('gpu_timing_ns', r.get('gpu_timing_ns')); print('status', r.get('status'))"
