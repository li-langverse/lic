#!/usr/bin/env bash
# PH-ML HPC AI library master gate — Stage 5 forward + no stub bar on Li competitive rows.
set -euo pipefail
ROOT="${PH_ML_HPC_AI_LIBRARY_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_HPC_AI_LIBRARY_ROOT='$wsl_root' PH_ML_HPC_AI_LIBRARY_INNER=1 && bash scripts/ph-ml-hpc-ai-library-gates.sh"
}

if [[ "${PH_ML_HPC_AI_LIBRARY_INNER:-0}" != "1" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export PH_ML_STAGE6_INNER=1
bash scripts/ph-ml-stage6-gates.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

comp = json.loads(Path("benchmarks/results/ph-ml-competitive.json").read_text())
for row in comp.get("rows") or []:
    li = row.get("li") or {}
    if not li.get("executed"):
        continue
    wc = li.get("workload_class") or "stub"
    if wc == "stub":
        sys.exit(f"hpc gate: executed Li row {row.get('id')!r} must not be workload_class=stub")
print("hpc gate: no stub bar on executed Li competitive rows")
PY

[[ -f data/goal-directed-sprints/ph-ml-hpc-ai-library-complete.md ]] \
  || { echo "missing ph-ml-hpc-ai-library-complete.md"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-stage6-httpd-native-prep.md ]] \
  || { echo "missing stage6 goal"; exit 1; }
[[ -f data/goal-directed-sprints/ph-ml-stage7-streaming-prep.md ]] \
  || { echo "missing stage7 prep goal"; exit 1; }

echo "ph-ml-hpc-ai-library: completion gate OK"
