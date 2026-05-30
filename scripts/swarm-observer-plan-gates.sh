#!/usr/bin/env bash
# Swarm observer orchestration gates — registry freshness + apply-actions artifact.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANGVERSE="$(cd "$ROOT/.." && pwd)"
BENCHMARKS="${BENCHMARKS_ROOT:-$LANGVERSE/benchmarks}"
STATE_DIR="${SWARM_OBSERVER_STATE_DIR:-$ROOT/data/swarm-observer-plan-loop}"
REGISTRY="$ROOT/data/swarm-gap-registry/registry.yaml"
ACTIONS="$BENCHMARKS/data/latest/swarm-gap-actions.json"
GRADE_JSON="$STATE_DIR/grade.json"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

fail() { echo "swarm-observer-plan-gates: $*" >&2; exit 1; }

registry_ok=1
registry_note="ok"
if [[ ! -f "$REGISTRY" ]]; then
  registry_ok=0
  registry_note="missing registry.yaml"
else
  if ! python3 -c "import yaml; yaml.safe_load(open('$REGISTRY'))" 2>/dev/null; then
    registry_ok=0
    registry_note="invalid YAML"
  fi
fi

ingest_ok=1
ingest_note="ok"
if [[ "${SWARM_GAP_INGEST_SKIP:-}" != "1" ]]; then
  if ! python3 "$ROOT/scripts/swarm-gap-ingest.py" --dry-run >/dev/null 2>&1; then
    ingest_ok=0
    ingest_note="ingest script failed"
  fi
fi

actions_ok=1
actions_note="ok"
if [[ -f "$ACTIONS" ]]; then
  actions_note="present"
else
  if [[ "${SWARM_GAP_ACTIONS_SKIP:-}" == "1" ]]; then
    actions_note="skip env"
  else
    actions_ok=0
    actions_note="missing swarm-gap-actions.json (run apply-actions)"
  fi
fi

study_ok=1
study_note="orchestration iteration"
if [[ -n "${SWARM_OBSERVER_REQUIRE_NOTE:-}" ]]; then
  note="$ROOT/${SWARM_OBSERVER_REQUIRE_NOTE}"
  if [[ ! -f "$note" ]]; then
    study_ok=0
    study_note="missing observer note: $SWARM_OBSERVER_REQUIRE_NOTE"
  fi
fi

overall=0
[[ "$registry_ok" -eq 1 && "$ingest_ok" -eq 1 && "$actions_ok" -eq 1 && "$study_ok" -eq 1 ]] && overall=1

mkdir -p "$STATE_DIR"
python3 - <<PY
import json
from pathlib import Path
grade = {
    "generated_at": "$STAMP",
    "vertical": "swarm_observer",
    "registry_ok": $registry_ok,
    "ingest_ok": $ingest_ok,
    "actions_ok": $actions_ok,
    "study_ok": $study_ok,
    "overall_pass": bool($overall),
    "notes": {
        "registry": "$registry_note",
        "ingest": "$ingest_note",
        "actions": "$actions_note",
        "study": "$study_note",
    },
}
Path("$GRADE_JSON").write_text(json.dumps(grade, indent=2) + "\\n")
print(json.dumps(grade, indent=2))
PY

[[ "$overall" -eq 1 ]] || fail "gates failed (registry=$registry_ok ingest=$ingest_ok actions=$actions_ok study=$study_ok)"
echo "swarm-observer-plan-gates: OK"
