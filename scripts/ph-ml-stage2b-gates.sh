#!/usr/bin/env bash
set -euo pipefail
ROOT="${PH_ML_STAGE2B_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"
export PH_ML_STAGE2B_INNER=1
export LIG_EMIT_CUDA=1
bash scripts/ph-ml-stage2-gates.sh
grep -q ml_matmul_tiled_dynamic packages/li-ml/src/lib.li
for smoke in packages/li-ml/li-tests/smoke/ml_matmul_tiled_dynamic.li \
  packages/li-ml/li-tests/smoke/ml_tensor_matmul_4.li \
  packages/li-ml/li-tests/smoke/ml_tensor_matmul_16.li; do
  ./build-wsl/compiler/lic/lic build --allow-open-vc "$smoke" -o /dev/null
done
bash scripts/bench-ph-ml-lkir-matmul-dynamic.sh
python3 -c "import json; d=json.load(open('benchmarks/results/ph-ml-lkir-matmul-dynamic.json')); assert d.get('executed') and d.get('validity_gate_pass')"
echo ph-ml-stage2b: completion gate OK
