#!/usr/bin/env bash
# PH-ML Stage 9 stretch — multi-layer transformer parity, cluster GPU KV, LLM competitors in CI.
set -euo pipefail
ROOT="${PH_ML_STAGE9_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE9_ROOT='$wsl_root' PH_ML_STAGE9_INNER=1 && bash scripts/ph-ml-stage9-gates.sh"
}

if [[ "${PH_ML_STAGE9_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

if [[ "${PH_ML_STAGE9_SKIP_STAGE8_CHAIN:-0}" != "1" ]]; then
  export PH_ML_STAGE8_INNER=1
  bash scripts/ph-ml-stage8-gates.sh
fi

# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
if [[ "${PH_ML_STAGE9_SKIP_STAGE8_CHAIN:-0}" == "1" ]]; then
  li_ensure_lic "$ROOT" || { echo "ph-ml-stage9-gates: build lic"; exit 1; }
else
  li_export_lic "$ROOT" || { echo "ph-ml-stage9-gates: build lic"; exit 1; }
fi

grep -q 'return 10' packages/li-llm/src/lib.li \
  || { echo "9.1: li_llm_version must be 10"; exit 1; }
grep -q 'llm_transformer_multilayer_fixture_top_id' packages/li-llm/src/lib.li \
  || { echo "9.2: missing multi-layer transformer parity"; exit 1; }
grep -q 'llm_kv_cluster_gpu_decode_progress' packages/li-llm/src/lib.li \
  || { echo "9.3: missing cluster GPU KV progress"; exit 1; }
grep -q 'llm_transformer_layer_count' packages/li-llm/src/lib.li \
  || { echo "9.4: missing transformer layer count"; exit 1; }

for smoke in \
  packages/li-llm/li-tests/smoke/llm_transformer_multilayer_parity.li \
  packages/li-llm/li-tests/smoke/llm_kv_cluster_gpu_decode.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

bash scripts/bench-ph-ml-llm-transformer-multilayer-parity.sh
bash scripts/bench-ph-ml-llm-kv-gpu-cluster.sh
bash scripts/bench-ph-ml-competitor-llm-all.sh
bash scripts/bench-ph-ml-competitive.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

root = Path("benchmarks/results")
ml = json.loads((root / "ph-ml-transformer-multilayer-parity.json").read_text())
if ml.get("reference_top_id") is None:
    sys.exit("9.5: multilayer reference_top_id missing")
if not ml.get("executed") or not ml.get("validity_gate_pass"):
    sys.exit("9.6: Li vs reference multilayer parity must pass")
if ml.get("li_top_id") != ml.get("reference_top_id"):
    sys.exit(f"9.6: li_top_id {ml.get('li_top_id')} != reference {ml.get('reference_top_id')}")

kv = json.loads((root / "ph-ml-llm-kv-gpu-cluster.json").read_text())
if kv.get("note") is None:
    sys.exit("9.7: kv gpu cluster bench missing note")
if kv.get("gpu_decode_progress") and not kv.get("lig_emit_cuda"):
    sys.exit("9.7: gpu_decode_progress requires LIG_EMIT")

for name in ("ph-ml-competitor-llamacpp.json", "ph-ml-competitor-vllm.json", "ph-ml-competitor-transformers.json"):
    row = json.loads((root / name).read_text())
    if row.get("note") is None:
        sys.exit(f"9.8: competitor {name} missing honest note")
    if row.get("executed") is None:
        sys.exit(f"9.8: competitor {name} missing executed flag")

comp = json.loads((root / "ph-ml-competitive.json").read_text())
if not any(r.get("id") == "llm_transformer_multilayer" for r in comp.get("rows") or []):
    sys.exit("9.9: ph-ml-competitive.json missing llm_transformer_multilayer row")
print("stage9 stretch OK", "multilayer=", ml.get("validity_gate_pass"), "kv_note=", kv.get("note")[:40])
PY

[[ -f data/goal-directed-sprints/ph-ml-stage9-stretch.md ]] \
  || { echo "missing stage9 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-06-ph-ml-stage9-stretch.md ]] \
  || { echo "missing stage9 release note"; exit 1; }

echo "ph-ml-stage9-stretch: completion gate OK"
