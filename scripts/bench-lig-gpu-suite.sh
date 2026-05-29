#!/usr/bin/env bash
# WP-BENCH-ML-05: honest GPU suite JSON (no fake ns timings).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/bench-lig-kernel-parity.sh"
PARITY="$ROOT/benchmarks/results/lig-lkir-matmul.json"
OUT="$ROOT/benchmarks/results/lig-gpu-suite-honest.json"
python3 - "$PARITY" "$OUT" <<'PY'
import json, sys
from pathlib import Path
parity_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
report = {
    "status": "honest_stub",
    "gpu_timing_ns": "N/A",
    "note": "SPIR-V emit blocked WP-HW-06; validity from CPU parity smoke only",
}
if parity_path.is_file():
    report["parity"] = json.loads(parity_path.read_text())
out_path.write_text(json.dumps(report, indent=2) + "\n")
print(out_path)
PY
