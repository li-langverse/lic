#!/usr/bin/env bash
# WP-BENCH-ML-05/06: honest GPU suite JSON (no fake ns timings).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/bench-lig-kernel-parity.sh"
PARITY="$ROOT/benchmarks/results/lig-lkir-matmul.json"
OUT="$ROOT/benchmarks/results/lig-gpu-suite-honest.json"
TIER3_STUB="$ROOT/benchmarks/results/tier3-ml-ingest-stub.json"
python3 - "$PARITY" "$OUT" "$TIER3_STUB" <<'PY'
import json, sys
from pathlib import Path
parity_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
tier3_path = Path(sys.argv[3])
report = {
    "status": "honest_stub",
    "wave": 4,
    "gpu_timing_ns": "N/A",
    "cuda_timing_ns": "N/A",
    "hip_timing_ns": "N/A",
    "vulkan_dispatch": "blocked",
    "spirv_validation": "header_smoke_only",
    "note": "SPIR-V dispatch blocked WP-HW-07; LIG_EMIT_CUDA/HIP return emit-stub status 1 only",
}
if parity_path.is_file():
    report["parity"] = json.loads(parity_path.read_text())
out_path.write_text(json.dumps(report, indent=2) + "\n")
tier3 = {
    "status": "ingest_stub",
    "wave": 4,
    "family": "ml",
    "gpu_timing_ns": "N/A",
    "note": "Tier-3 dashboard ingest placeholder until real oracle CSV lands",
}
tier3_path.write_text(json.dumps(tier3, indent=2) + "\n")
print(out_path)
print(tier3_path)
PY
