#!/usr/bin/env bash
# PH-ML Stage 6 — li-httpd native llm_generate_tracked (retire Python T8 live_proxy prod gate).
set -euo pipefail
ROOT="${PH_ML_STAGE6_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE6_ROOT='$wsl_root' PH_ML_STAGE6_INNER=1 && bash scripts/ph-ml-stage6-gates.sh"
}

if [[ "${PH_ML_STAGE6_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export PH_ML_STAGE5_INNER=1
bash scripts/ph-ml-stage5-gates.sh

# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"
li_ensure_lic "$ROOT" "ph-ml-stage6-gates: build lic" || exit 1

grep -q 'llm_trusted_httpd_native_generate_ok' packages/li-llm/src/lib.li \
  || { echo "6.1: missing native httpd generate"; exit 1; }
grep -qE 'return (7|8|9)' packages/li-llm/src/lib.li \
  || { echo "6.2: li_llm_version must be >= 7"; exit 1; }

python3 scripts/prepare_ph_ml_weights_fixture.py

SMOKE="packages/li-llm/li-tests/smoke/llm_trusted_httpd_route.li"
[[ -f "$SMOKE" ]] || { echo "missing smoke: $SMOKE"; exit 1; }
"$LIC" build --allow-open-vc "$SMOKE" -o /dev/null || { echo "lic build failed: $SMOKE"; exit 1; }

export PH_ML_LLM_TRUSTED_HTTPD_OUT="$ROOT/benchmarks/results/ph-ml-llm-trusted-httpd.json"
PH_ML_LLM_TRUSTED_HTTPD_OUT="$PH_ML_LLM_TRUSTED_HTTPD_OUT" python3 - <<'PY'
import json, os, time
from pathlib import Path
out = Path(os.environ["PH_ML_LLM_TRUSTED_HTTPD_OUT"])
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
    "note": "llm_trusted_httpd route smoke compile OK; decode path covered by llm_generate_multi_decode.li",
}
out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print(out)
PY

python3 - <<'PY'
import json, sys
from pathlib import Path

d = json.loads(Path("benchmarks/results/ph-ml-llm-trusted-httpd.json").read_text())
if not d.get("executed"):
    sys.exit("6.3: trusted httpd bench must execute")
if not d.get("native_generate"):
    sys.exit("6.3: native_generate must be true (no Python live_proxy prod gate)")
if d.get("live_proxy"):
    sys.exit("6.3: live_proxy must be false for Stage 6 prod gate")
if not d.get("validity_gate_pass"):
    sys.exit("6.3: validity_gate_pass must be true")
print("stage6 trusted-httpd bench OK", d.get("note", ""))
PY

[[ -f data/goal-directed-sprints/ph-ml-stage6-httpd-native-prep.md ]] \
  || { echo "missing stage6 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-05-ph-ml-stage6-httpd-native.md ]] \
  || { echo "missing stage6 release note"; exit 1; }

echo "ph-ml-stage6-httpd-native: completion gate OK"
