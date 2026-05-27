#!/usr/bin/env bash
# Research gates: validity (hard) + perf + memory + optional security; grade.json for canvas.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LIC_ROOT="${LIC_ROOT:-$ROOT}"
# bench_sim.py uses $LIC; resolve so full gates do not fail when cwd LIC is wrong.
if [[ -z "${LIC:-}" || ! -x "${LIC}" ]]; then
  export LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi

VERT="${SIM_RESEARCH_VERTICAL:-}"
if [[ "$VERT" != "md" && "$VERT" != "chem" ]]; then
  echo "sim-algo-research-gates: set SIM_RESEARCH_VERTICAL=md|chem" >&2
  exit 1
fi

STATE_DIR="${SIM_RESEARCH_STATE_DIR:-$ROOT/data/sim-${VERT}-research-loop}"
mkdir -p "$STATE_DIR"
GRADE_JSON="$STATE_DIR/grade.json"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

fail() { echo "sim-algo-research-gates: $*" >&2; exit 1; }

case "$VERT" in
  md)
    export SIM_PLAN_PACKAGE="${SIM_PLAN_PACKAGE:-li-sim-scientific}"
    export SIM_RESEARCH_BENCHES="${SIM_RESEARCH_BENCHES:-md_lennard_jones,heat_equation_2d}"
    ;;
  chem)
    export SIM_PLAN_PACKAGE="${SIM_PLAN_PACKAGE:-li-sim-scientific}"
    export SIM_RESEARCH_BENCHES="${SIM_RESEARCH_BENCHES:-}"
    ;;
esac

# Study-only mode requires explicit backlog flag (WP-LIC-04) — env alone cannot bypass benches.
if [[ "${SIM_RESEARCH_STUDY_ONLY:-0}" == "1" && "${SIM_RESEARCH_BACKLOG_STUDY_ONLY:-0}" != "1" ]]; then
  echo "sim-algo-research-gates: SIM_RESEARCH_STUDY_ONLY=1 rejected (set study_only: true on backlog todo)" >&2
  exit 1
fi
STUDY_ONLY="${SIM_RESEARCH_BACKLOG_STUDY_ONLY:-0}"

validity_ok=1
perf_ok=1
memory_ok=1
security_ok=1
security_note="skip"
stability_ok=1
size_scaling_ok=1
gate_log=""

if [[ "$STUDY_ONLY" == "1" ]]; then
  validity_ok=1
  gate_log="study-only iteration (no bench gates)"
  if [[ -n "${SIM_RESEARCH_REQUIRE_STUDY:-}" ]]; then
    if [[ ! -f "$ROOT/${SIM_RESEARCH_REQUIRE_STUDY}" ]]; then
      validity_ok=0
      gate_log="missing required study: ${SIM_RESEARCH_REQUIRE_STUDY}"
    fi
  fi
else
  echo "==> sim-algo-research-gates vertical=$VERT package=$SIM_PLAN_PACKAGE"
  if ! bash "$ROOT/scripts/sim-plan-gates.sh" 2>&1 | tee /tmp/sim-research-gates-last.log; then
    validity_ok=0
    perf_ok=0
    memory_ok=0
  fi
fi
export SIM_RESEARCH_SECURITY_NOTE="$security_note"

if [[ "$VERT" == "chem" && "$STUDY_ONLY" != "1" ]]; then
  comp="$ROOT/li-tests/composable/import_chem_dft_smoke.li"
  if [[ -f "$comp" && -x "${LIC:-$LIC_ROOT/build/compiler/lic/lic}" ]]; then
    LIC_BIN="${LIC:-$LIC_ROOT/build/compiler/lic/lic}"
    if ! "$LIC_BIN" build "$comp" >/dev/null 2>&1; then
      validity_ok=0
      gate_log="${gate_log}\nchem composable import_chem_dft_smoke failed"
    fi
  fi
fi

if [[ "${SIM_RESEARCH_TOUCHED_NATIVE:-0}" == "1" ]]; then
  security_note="li-tests security slice"
  if [[ -x "$ROOT/li-tests/run_security.sh" ]]; then
    if ! "$ROOT/li-tests/run_security.sh" 2>&1 | tail -n 20; then
      security_ok=0
    fi
  elif [[ -x "$ROOT/scripts/ci-security.sh" ]]; then
    if ! "$ROOT/scripts/ci-security.sh" 2>&1 | tail -n 30; then
      security_ok=0
    fi
  else
    security_note="no security runner found"
  fi
fi

overall_ok=1
if [[ "$validity_ok" -ne 1 || "$security_ok" -ne 1 ]]; then
  overall_ok=0
fi

export SIM_RESEARCH_GRADE_JSON="$GRADE_JSON"
export SIM_RESEARCH_GRADE_STAMP="$STAMP"
export SIM_RESEARCH_VALIDITY_OK="$validity_ok"
export SIM_RESEARCH_PERF_OK="$perf_ok"
export SIM_RESEARCH_MEMORY_OK="$memory_ok"
export SIM_RESEARCH_SECURITY_OK="$security_ok"
export SIM_RESEARCH_STABILITY_OK="$stability_ok"
export SIM_RESEARCH_SIZE_OK="$size_scaling_ok"
export SIM_RESEARCH_OVERALL_OK="$overall_ok"
python3 - <<'PY'
import json
import os
from pathlib import Path

log_path = Path("/tmp/sim-research-gates-last.log")
tail = log_path.read_text(encoding="utf-8", errors="replace")[-2000:] if log_path.is_file() else ""

doc = {
    "generated_at": os.environ["SIM_RESEARCH_GRADE_STAMP"],
    "vertical": os.environ["SIM_RESEARCH_VERTICAL"],
    "validity_ok": os.environ["SIM_RESEARCH_VALIDITY_OK"] == "1",
    "perf_ok": os.environ["SIM_RESEARCH_PERF_OK"] == "1",
    "memory_ok": os.environ["SIM_RESEARCH_MEMORY_OK"] == "1",
    "security_ok": os.environ["SIM_RESEARCH_SECURITY_OK"] == "1",
    "security_note": os.environ.get("SIM_RESEARCH_SECURITY_NOTE", "skip"),
    "stability_ok": os.environ["SIM_RESEARCH_STABILITY_OK"] == "1",
    "size_scaling_ok": os.environ["SIM_RESEARCH_SIZE_OK"] == "1",
    "study_only": os.environ.get("SIM_RESEARCH_BACKLOG_STUDY_ONLY", "0") == "1",
    "overall_ok": os.environ["SIM_RESEARCH_OVERALL_OK"] == "1",
    "package": os.environ.get("SIM_PLAN_PACKAGE", ""),
    "benches": os.environ.get("SIM_RESEARCH_BENCHES", ""),
    "gate_log_tail": tail,
}
Path(os.environ["SIM_RESEARCH_GRADE_JSON"]).write_text(json.dumps(doc, indent=2) + "\n")
PY

if [[ "$overall_ok" -ne 1 ]]; then
  fail "hard gate failed (validity=$validity_ok security=$security_ok) — see $GRADE_JSON"
fi
echo "sim-algo-research-gates: ok ($GRADE_JSON)"
