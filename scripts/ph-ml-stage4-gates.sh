#!/usr/bin/env bash
# PH-ML Stage 4 — LLM import pipeline (safetensors/GGUF parse, lillm import, tier-3 bench).
set -euo pipefail
ROOT="${PH_ML_STAGE4_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE4_ROOT='$wsl_root' PH_ML_STAGE4_INNER=1 && bash scripts/ph-ml-stage4-gates.sh"
}

if [[ "${PH_ML_STAGE4_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
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
[[ -x "$LIC" ]] || { echo "ph-ml-stage4-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

bash scripts/ph-ml-program-complete-gates.sh

grep -q 'li_rt_llm_safetensors_probe_path' packages/li-llm/src/lib.li \
  || { echo "4.1: missing real safetensors parse extern"; exit 1; }
grep -q 'llm_gguf_parse_header' packages/li-llm/src/lib.li \
  || { echo "4.2: missing GGUF header parse"; exit 1; }
grep -q 'llm_import_model_path_default' packages/li-llm/src/lib.li \
  || { echo "4.3: missing documented import path"; exit 1; }
[[ -f runtime/li_rt_llm.c ]] || { echo "4.1: missing runtime/li_rt_llm.c"; exit 1; }

export PH_ML_WEIGHTS_FIXTURE="${PH_ML_WEIGHTS_FIXTURE:-$ROOT/packages/li-llm/fixtures/ph-ml-weights}"
python3 scripts/prepare_ph_ml_weights_fixture.py
mkdir -p "$ROOT/benchmarks/fixtures/ph-ml-weights"
cp -f "$PH_ML_WEIGHTS_FIXTURE/model.safetensors" "$ROOT/benchmarks/fixtures/ph-ml-weights/"
cp -f "$PH_ML_WEIGHTS_FIXTURE/model.gguf" "$ROOT/benchmarks/fixtures/ph-ml-weights/"

export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
for smoke in \
  packages/li-llm/li-tests/smoke/llm_safetensors_parse_real.li \
  packages/li-llm/li-tests/smoke/llm_gguf_header.li \
  packages/li-llm/li-tests/smoke/llm_import_fixture_path.li \
  packages/li-llm/li-tests/smoke/llm_weights_file_mmap.li \
  packages/li-llm/li-tests/smoke/llm_forward.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

LILLM_IMPORT_OFFLINE=1 bash scripts/lillm-import.sh meta-llama/Llama-3.2-1B-Instruct packages/li-llm/fixtures/imported/stage4-smoke
[[ -f packages/li-llm/fixtures/imported/stage4-smoke/manifest.json ]] \
  || { echo "4.3: lillm-import offline manifest missing"; exit 1; }

bash scripts/bench-ph-ml-llm-forward.sh
bash scripts/bench-ph-ml-competitive.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

root = Path("benchmarks/results")
fwd = json.loads((root / "ph-ml-llm-forward.json").read_text())
if not fwd.get("executed") or not fwd.get("validity_gate_pass"):
    sys.exit("4.4: ph-ml-llm-forward must execute with validity_gate_pass")
if not fwd.get("tensor_metadata_ok"):
    sys.exit("4.4: tensor_metadata_ok must be true (real safetensors smokes)")
if fwd.get("workload_class") != "pilot":
    sys.exit("4.4: workload_class must be pilot when tensor metadata OK")

comp = json.loads((root / "ph-ml-competitive.json").read_text())
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
llm_row = rows.get("llm_forward") or {}
if llm_row.get("workload_class") != "pilot":
    sys.exit("4.4: competitive llm_forward workload_class must be pilot")
li = llm_row.get("li") or {}
if not li.get("executed"):
    sys.exit("4.4: competitive llm_forward li.executed must be true")
print("stage4 benches OK", "cpu_sec=", fwd.get("cpu_sec"), "workload_class=", fwd.get("workload_class"))
PY

[[ -f data/goal-directed-sprints/ph-ml-stage4-llm-import.md ]] \
  || { echo "missing stage4 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-04-ph-ml-stage4-llm-import.md ]] \
  || { echo "missing stage4 release note"; exit 1; }
grep -q 'Stage 4' docs/game-dev/PH-ML-GPU-battle-plan.md \
  || { echo "battle plan missing Stage 4 row"; exit 1; }
grep -q 'WP-LLM-13' docs/game-dev/PH-ML-GPU-execution-tracker.md \
  || { echo "tracker missing Stage 4 WPs"; exit 1; }

echo "ph-ml-stage4-llm-import: completion gate OK"
