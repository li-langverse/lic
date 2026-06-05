#!/usr/bin/env bash
# PH-ML Stage 8 — production SSE route, full MLP backward, GPU KV, LLM competitors, logits oracle.
set -euo pipefail
ROOT="${PH_ML_STAGE8_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE8_ROOT='$wsl_root' PH_ML_STAGE8_INNER=1 && bash scripts/ph-ml-stage8-gates.sh"
}

if [[ "${PH_ML_STAGE8_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export PH_ML_STAGE7_INNER=1
bash scripts/ph-ml-stage7-gates.sh

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
[[ -x "$LIC" ]] || { echo "ph-ml-stage8-gates: build lic"; exit 1; }

grep -q 'return 9' packages/li-llm/src/lib.li \
  || { echo "8.1: li_llm_version must be 9"; exit 1; }
grep -q 'llm_streaming_sse_production_ok' packages/li-llm/src/lib.li \
  || { echo "8.2: missing production SSE oracle"; exit 1; }
grep -q 'llm_logits_oracle_parity_ok' packages/li-llm/src/lib.li \
  || { echo "8.3: missing logits oracle parity"; exit 1; }
grep -q 'ml_autograd_matmul_backward_f32' packages/li-ml/src/lib.li \
  || { echo "8.4: missing full MLP backward"; exit 1; }

for smoke in \
  packages/li-llm/li-tests/smoke/llm_streaming_sse_production.li \
  packages/li-llm/li-tests/smoke/llm_logits_oracle_parity.li \
  packages/li-llm/li-tests/smoke/llm_kv_device_buffer.li \
  packages/li-ml/li-tests/smoke/ml_autograd_full_backward.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

bash scripts/build-inference-native-backend.sh
[[ -x "$ROOT/build/inference-native-backend" ]] \
  || { echo "8.5: inference-native-backend missing"; exit 1; }

if [[ -x "$ROOT/build/li-httpd" || -x "$ROOT/scripts/build-li-httpd.sh" ]]; then
  if [[ ! -x "$ROOT/build/li-httpd" ]]; then
    bash "$ROOT/scripts/build-li-httpd.sh"
  fi
  HTTPD_RUN_M15_ORACLE_RUNTIME="${HTTPD_RUN_M15_ORACLE_RUNTIME:-1}" \
    bash "$ROOT/scripts/test-m15-inference-live.sh"
fi

bash scripts/bench-ph-ml-llm-logits-oracle.sh
bash scripts/bench-ph-ml-competitor-llm-all.sh
bash scripts/bench-ph-ml-mlp-train-step.sh
export PH_ML_LI_TRAIN_LOSS="2.0" PH_ML_LI_DW1_00="1.0" PH_ML_LI_DW2_00="1.0"
python3 scripts/bench_ph_ml_mlp_train_parity.py

python3 - <<'PY'
import json, sys
from pathlib import Path

root = Path("benchmarks/results")
train = json.loads((root / "ph-ml-mlp-train-step.json").read_text())
if train.get("autograd_mode") != "full_backward":
    sys.exit("8.6: autograd_mode must be full_backward")
parity = json.loads((root / "ph-ml-mlp-train-parity.json").read_text())
if not parity.get("executed") or not parity.get("validity_gate_pass"):
    sys.exit("8.7: PyTorch parity bench must pass")

logits = json.loads((root / "ph-ml-llm-logits-oracle.json").read_text())
if not logits.get("executed") or not logits.get("validity_gate_pass"):
    sys.exit("8.8: logits oracle bench must execute")

for name in ("ph-ml-competitor-llamacpp.json", "ph-ml-competitor-vllm.json", "ph-ml-competitor-transformers.json"):
    p = root / name
    if not p.is_file():
        sys.exit(f"8.9: missing competitor bench {name}")
    row = json.loads(p.read_text())
    if row.get("note") is None:
        sys.exit(f"8.9: competitor {name} must have honest note")

comp = json.loads((root / "ph-ml-competitive.json").read_text())
llm_row = next((r for r in comp.get("rows", []) if r.get("id") == "llm_forward"), {})
for c in llm_row.get("competitors") or []:
    if c.get("note") is None:
        sys.exit(f"8.10: llm competitor {c.get('id')} missing note")
print("stage8 benches OK", "train=", train.get("autograd_mode"), "parity=", parity.get("validity_gate_pass"))
PY

[[ -f data/goal-directed-sprints/ph-ml-stage8-production.md ]] \
  || { echo "missing stage8 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-05-ph-ml-stage8-production.md ]] \
  || { echo "missing stage8 release note"; exit 1; }

echo "ph-ml-stage8-production: completion gate OK"
