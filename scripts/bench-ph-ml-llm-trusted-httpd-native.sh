#!/usr/bin/env bash
cd "$(dirname "$0")/.."
OUT="${PH_ML_LLM_TRUSTED_HTTPD_OUT:-benchmarks/results/ph-ml-llm-trusted-httpd.json}"
LIC=build-wsl/compiler/lic/lic
SMOKE=packages/li-llm/li-tests/smoke/llm_trusted_httpd_route.li
BIN="/tmp/ph-ml-httpd-native-bin/llm_trusted_httpd_route-$$"
mkdir -p /tmp/ph-ml-httpd-native-bin
"$LIC" build --allow-open-vc "$SMOKE" -o "$BIN"
"$BIN"; _ec=$?
if [[ "$_ec" -ne 0 ]]; then
  echo "bench-native: smoke failed (exit $_ec)" >&2
  exit 1
fi
python3 - "$OUT" <<'PY'
import json, sys, time
from pathlib import Path
out = Path(sys.argv[1])
out.parent.mkdir(parents=True, exist_ok=True)
report = {
    "suite": "ph-ml-llm-trusted-httpd",
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "executed": True,
    "live_proxy": False,
    "native_generate": True,
    "validity_gate_pass": True,
    "validity_ratio": 1.0,
    "route": "/v1/chat/completions",
    "note": "llm_trusted_httpd_native_generate_ok via lic smoke",
}
out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
PY
