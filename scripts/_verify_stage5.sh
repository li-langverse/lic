#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CC=clang-22 CXX=clang++-22 LIC=./build-wsl/compiler/lic/lic
export BENCHMARKS_RESULTS="$PWD/benchmarks/results"
bash scripts/bench-ph-ml-llm-forward.sh
bash scripts/bench-ph-ml-competitive.sh
python3 - <<'PY'
import json, sys
from pathlib import Path
d = json.loads(Path("benchmarks/results/ph-ml-llm-forward.json").read_text())
if not d.get("validity_gate_pass") or not d.get("forward_matmul_ok"):
    sys.exit(f"bench fail: {d}")
print("bench OK", d.get("workload_class"))
comp = json.loads(Path("benchmarks/results/ph-ml-competitive.json").read_text())
li = next(r for r in comp["rows"] if r["id"] == "llm_forward")["li"]
if (li.get("workload_class") or "stub") == "stub":
    sys.exit(f"competitive stub: {li}")
print("competitive OK", li.get("workload_class"))
PY
for s in packages/li-llm/li-tests/smoke/llm_forward_matmul_real.li packages/li-llm/li-tests/smoke/llm_generate_multi_decode.li; do
  "$LIC" build --allow-open-vc "$s" -o /dev/null
done
echo "stage5-verify: OK"
