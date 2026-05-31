#!/usr/bin/env bash
# Phase 4 — Li coverage invariant (every row: li_specimen or explicit open gap).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
for gate in wp-li-coverage; do
  script="scripts/proof-explorer-gates/${gate}.sh"
  if [[ -f "$script" ]]; then
    bash "$script" || fail=1
  else
    echo "phase4: missing $script" >&2
    fail=1
  fi
done

if [[ ! -f data/proof-explorer-loop/wp-li-coverage.signoff ]]; then
  echo "phase4: wp-li-coverage signoff missing" >&2
  fail=1
fi

report="data/proof-explorer-loop/li-coverage-report.json"
if [[ ! -f "$report" ]]; then
  echo "phase4: missing $report (run wp-li-coverage)" >&2
  fail=1
else
  read -r t3_pct overall < <(python3 - <<'PY'
import json
from pathlib import Path
s = json.loads(Path("data/proof-explorer-loop/li-coverage-report.json").read_text())["summary"]
print(int(s["T3_pct"]), int(s["pct_overall"]))
PY
)
  if [[ "$t3_pct" -lt 100 ]]; then
    echo "phase4: T3 (literature-proved Erdos) at ${t3_pct} pct (need 100)" >&2
    fail=1
  else
    echo "phase4: T3 coverage OK (${t3_pct} pct)"
  fi
  if [[ "$overall" -lt 100 ]]; then
    echo "phase4: overall Li coverage ${overall} pct (need 100)" >&2
    fail=1
  else
    echo "phase4: overall coverage OK (${overall} pct)"
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "proof-explorer-phase4-completion-gate: INCOMPLETE"
  exit 1
fi
echo "proof-explorer-phase4-completion-gate: OK"
exit 0
