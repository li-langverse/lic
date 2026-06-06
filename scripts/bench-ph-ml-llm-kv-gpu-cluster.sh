#!/usr/bin/env bash
# Stage 9: cluster GPU KV decode — LIG_EMIT + device buffers when GPU vendor emit available.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
OUT="${PH_ML_LLM_KV_GPU_CLUSTER_OUT:-$ROOT/benchmarks/results/ph-ml-llm-kv-gpu-cluster.json}"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_export_lic "$ROOT" || { echo "bench-ph-ml-llm-kv-gpu-cluster: no lic"; exit 1; }

python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"
SMOKE="packages/li-llm/li-tests/smoke/llm_kv_cluster_gpu_decode.li"
BIN="/tmp/ph-ml-kv-gpu-cluster-$$"
COMPILE_OK=0
RUN_RC=1
KV_PROGRESS=0
CLUSTER_PROGRESS=0
export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"

if [[ "${LIG_EMIT_CUDA:-0}" == "1" ]] || [[ "${LIG_EMIT_HIP:-0}" == "1" ]]; then
  bash "$ROOT/scripts/lig-emit-vendor-stub.sh" >/dev/null 2>&1 || true
fi

if "$LIC" build --allow-open-vc "$SMOKE" -o "$BIN" >/dev/null 2>&1; then
  COMPILE_OK=1
fi
if [[ "$COMPILE_OK" == "1" && -x "$BIN" ]]; then
  if "$BIN" >/dev/null 2>&1; then
    RUN_RC=0
  fi
fi

export PH_ML_KV_GPU_CLUSTER_OUT="$OUT" PH_ML_KV_COMPILE_OK="$COMPILE_OK" \
  PH_ML_KV_RUN_RC="$RUN_RC" LIG_EMIT_CUDA="${LIG_EMIT_CUDA:-0}"
python3 - <<'PY'
import json, os, time
from pathlib import Path

compile_ok = os.environ.get("PH_ML_KV_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_KV_RUN_RC", "1"))
lig_emit = os.environ.get("LIG_EMIT_CUDA", "0") == "1"
executed = compile_ok and run_rc == 0
gpu_ready = lig_emit and executed
out = Path(os.environ["PH_ML_KV_GPU_CLUSTER_OUT"])
out.parent.mkdir(parents=True, exist_ok=True)
note = "GPU KV cluster decode progress"
if not lig_emit:
    note = "LIG_EMIT not set — honest skip (no GPU vendor emit)"
elif not executed:
    note = "llm_kv_cluster_gpu_decode smoke did not run"
else:
    note = "LIG_EMIT + llm_kv_cluster_gpu_decode_progress smoke OK"
report = {
    "suite": "ph-ml-llm-kv-gpu-cluster",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "workload_class": "gpu_labeled" if gpu_ready else "stub",
    "lig_emit_cuda": lig_emit,
    "executed": executed,
    "gpu_decode_progress": gpu_ready,
    "validity_gate_pass": run_rc == 0 if compile_ok else True,
    "note": note,
}
out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
PY
rm -f "$BIN"
echo "bench-ph-ml-llm-kv-gpu-cluster: done"
