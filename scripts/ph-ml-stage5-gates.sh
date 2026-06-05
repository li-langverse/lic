#!/usr/bin/env bash
# PH-ML Stage 5 — transformer forward (ml_matmul_f32) + multi-token decode (>=8 steps).
set -euo pipefail
ROOT="${PH_ML_STAGE5_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  export LIC="$ROOT/build-wsl/compiler/lic/lic"
fi

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE5_ROOT='$wsl_root' PH_ML_STAGE5_INNER=1 && bash scripts/ph-ml-stage5-gates.sh"
}

if [[ "${PH_ML_STAGE5_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export BENCHMARKS_ALLOW_NO_HARNESS=1
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
[[ -x "$LIC" ]] || { echo "ph-ml-stage5-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

bash scripts/ph-ml-stage4-gates.sh

grep -q 'llm_forward_matmul_top_id' packages/li-llm/src/lib.li \
  || { echo "5.1: missing matmul forward"; exit 1; }
grep -q 'llm_generate_tracked' packages/li-llm/src/lib.li \
  || { echo "5.2: missing tracked decode"; exit 1; }
grep -qE 'return (6|7|8)' packages/li-llm/src/lib.li \
  || { echo "5.3: li_llm_version must be >= 6"; exit 1; }

for smoke in \
  packages/li-llm/li-tests/smoke/llm_forward_matmul_real.li \
  packages/li-llm/li-tests/smoke/llm_generate_multi_decode.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

bash scripts/bench-ph-ml-llm-forward.sh
bash scripts/bench-ph-ml-competitive.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

root = Path("benchmarks/results")
fwd = json.loads((root / "ph-ml-llm-forward.json").read_text())
if not fwd.get("executed") or not fwd.get("validity_gate_pass"):
    sys.exit("5.4: ph-ml-llm-forward must execute with validity_gate_pass")
if not fwd.get("forward_matmul_ok"):
    sys.exit("5.4: forward_matmul_ok must be true (real matmul smokes)")
wc = fwd.get("workload_class")
if wc not in ("tier3_cpu", "pilot"):
    sys.exit(f"5.4: workload_class must be tier3_cpu or pilot, got {wc!r}")

comp = json.loads((root / "ph-ml-competitive.json").read_text())
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
llm_row = rows.get("llm_forward") or {}
li = llm_row.get("li") or {}
if (li.get("workload_class") or "stub") == "stub":
    sys.exit("5.4: competitive llm_forward li.workload_class must not be stub")
if not li.get("executed"):
    sys.exit("5.4: competitive llm_forward li.executed must be true")
print("stage5 benches OK", "cpu_sec=", fwd.get("cpu_sec"), "workload_class=", wc)
PY

[[ -f data/goal-directed-sprints/ph-ml-stage5-transformer-forward.md ]] \
  || { echo "missing stage5 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-04-ph-ml-stage5-transformer-forward.md ]] \
  || { echo "missing stage5 release note"; exit 1; }
grep -q 'Stage 5' docs/game-dev/PH-ML-GPU-battle-plan.md \
  || { echo "battle plan missing Stage 5 row"; exit 1; }
grep -q 'WP-LLM-14' docs/game-dev/PH-ML-GPU-execution-tracker.md \
  || { echo "tracker missing WP-LLM-14"; exit 1; }

echo "ph-ml-stage5-transformer-forward: completion gate OK"
