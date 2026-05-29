#!/usr/bin/env bash
# WP-BENCH-ML-05/06: honest GPU suite JSON (no fake ns timings).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/bench-lig-kernel-parity.sh"
PARITY="$ROOT/benchmarks/results/lig-lkir-matmul.json"
OUT="$ROOT/benchmarks/results/lig-gpu-suite-honest.json"
TIER3_STUB="$ROOT/benchmarks/results/tier3-ml-ingest-stub.json"
export LIG_EMIT_CUDA="${LIG_EMIT_CUDA:-0}"
export LIG_EMIT_HIP="${LIG_EMIT_HIP:-0}"
export LIG_VULKAN_LAVA="${LIG_VULKAN_LAVA:-0}"
python3 - "$PARITY" "$OUT" "$TIER3_STUB" <<'PY'
import json, os, sys
from pathlib import Path

parity_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
tier3_path = Path(sys.argv[3])

def env_on(name: str) -> bool:
    v = os.environ.get(name, "")
    return v not in ("", "0")

cuda_emit = env_on("LIG_EMIT_CUDA")
hip_emit = env_on("LIG_EMIT_HIP")
vulkan_lava = env_on("LIG_VULKAN_LAVA")

report = {
    "status": "honest_stub",
    "wave": "4b",
    "gpu_timing_ns": "N/A",
    "cuda_timing_ns": "N/A",
    "hip_timing_ns": "N/A",
    "vulkan_dispatch": "spirv_validation_stub_ok",
    "spirv_validation": "header_smoke_extended",
    "cuda_emit_status": 1 if cuda_emit else "emit_off",
    "hip_emit_status": 1 if hip_emit else "emit_off",
    "vulkan_lavapipe_hint": vulkan_lava,
    "note": (
        "No GPU ns timings. cuda/hip emit=1 is host CPU ref matmul when enabled; "
        "vulkan bid=5 returns stub_ok after SPIR-V header validation (WP-HW-07)."
    ),
}
if parity_path.is_file():
    report["parity"] = json.loads(parity_path.read_text())
    pr = report["parity"]
    if pr.get("validity_gate_pass"):
        report["host_validity_ratio"] = pr.get("validity_ratio", "N/A")
if cuda_emit and not env_on("CUDA_HOME") and not os.environ.get("CUDA_PATH"):
    report["cuda_cpu_ref"] = "emit_on_no_cuda_home_ratio_may_be_zero"
elif cuda_emit:
    report["cuda_cpu_ref"] = "2x2_host_reference_when_cuda_home_set"

out_path.write_text(json.dumps(report, indent=2) + "\n")
tier3 = {
    "status": "ingest_stub",
    "wave": "4b",
    "family": "ml",
    "gpu_timing_ns": "N/A",
    "note": "Tier-3 dashboard ingest placeholder until real oracle CSV lands",
}
tier3_path.write_text(json.dumps(tier3, indent=2) + "\n")
print(out_path)
print(tier3_path)
PY
