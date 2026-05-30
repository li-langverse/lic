#!/usr/bin/env bash
# Security research gates: CWE feed freshness (hard) + study-only + optional li-tests slice.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export LIC_ROOT="${LIC_ROOT:-$ROOT}"
LANGVERSE="$(cd "$ROOT/.." && pwd)"
BENCH="${BENCH_ROOT:-$LANGVERSE/benchmarks}"

STATE_DIR="${SECURITY_RESEARCH_STATE_DIR:-$ROOT/data/security-research-loop}"
mkdir -p "$STATE_DIR"
GRADE_JSON="$STATE_DIR/grade.json"
STAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

fail() { echo "security-research-gates: $*" >&2; exit 1; }

if [[ "${SECURITY_RESEARCH_STUDY_ONLY:-0}" == "1" && "${SECURITY_RESEARCH_BACKLOG_STUDY_ONLY:-0}" != "1" ]]; then
  echo "security-research-gates: SECURITY_RESEARCH_STUDY_ONLY=1 rejected (set study_only: true on backlog todo)" >&2
  exit 1
fi
STUDY_ONLY="${SECURITY_RESEARCH_BACKLOG_STUDY_ONLY:-0}"
posture_ok=1
cwe_feed_ok=1
tier5_ok=1
asan_ok=1
security_note="skip"
gate_log=""

# CWE feed freshness (benchmarks)
FEED_JSON="$BENCH/data/latest/security-cwe-feed.json"
if [[ "${SECURITY_CWE_FEED_SKIP:-0}" != "1" ]]; then
  if [[ ! -f "$FEED_JSON" ]]; then
    cwe_feed_ok=0
    gate_log="missing security-cwe-feed.json — run security-cwe-feed-sync.py"
  else
    age_days="$(python3 - <<PY
import json
from datetime import datetime, timezone
from pathlib import Path
p = Path("$FEED_JSON")
doc = json.loads(p.read_text())
ts = doc.get("generated_at") or doc.get("synced_at") or ""
if not ts:
    print(999)
else:
    t = datetime.fromisoformat(ts.replace("Z", "+00:00"))
    print(int((datetime.now(timezone.utc) - t).total_seconds() // 86400))
PY
)"
    if [[ "$age_days" -gt 7 ]]; then
      cwe_feed_ok=0
      gate_log="CWE feed stale (${age_days}d > 7) — run benchmarks/scripts/security-cwe-feed-sync.py"
    fi
  fi
else
  security_note="CWE feed check skipped (SECURITY_CWE_FEED_SKIP=1)"
fi

if [[ "$STUDY_ONLY" == "1" ]]; then
  gate_log="${gate_log}study-only iteration"
  if [[ -n "${SECURITY_RESEARCH_REQUIRE_STUDY:-}" ]]; then
    if [[ ! -f "$ROOT/${SECURITY_RESEARCH_REQUIRE_STUDY}" ]]; then
      posture_ok=0
      gate_log="${gate_log}; missing study: ${SECURITY_RESEARCH_REQUIRE_STUDY}"
    fi
  fi
  cwe_feed_ok=1
else
  if [[ -x "$ROOT/li-tests/run_security.sh" ]]; then
    security_note="li-tests security slice"
    if ! "$ROOT/li-tests/run_security.sh" 2>&1 | tail -n 25; then
      asan_ok=0
      posture_ok=0
    fi
  elif [[ -x "$ROOT/scripts/ci-security.sh" ]]; then
    security_note="ci-security.sh"
    if ! "$ROOT/scripts/ci-security.sh" 2>&1 | tail -n 30; then
      asan_ok=0
      posture_ok=0
    fi
  fi
fi

if [[ "${SECURITY_RESEARCH_TOUCHED_TIER5:-0}" == "1" ]]; then
  tier5_ok=1
  t5="$LANGVERSE/benchmarks/tier5_http"
  if [[ -d "$t5" ]]; then
    gate_log="${gate_log}; tier5 touched — verify exploit row in study"
  fi
fi

overall_ok=1
if [[ "$posture_ok" -ne 1 || "$cwe_feed_ok" -ne 1 || "$asan_ok" -ne 1 ]]; then
  overall_ok=0
fi

export SECURITY_RESEARCH_GRADE_JSON="$GRADE_JSON"
export SECURITY_RESEARCH_GRADE_STAMP="$STAMP"
export SECURITY_RESEARCH_POSTURE_OK="$posture_ok"
export SECURITY_RESEARCH_CWE_FEED_OK="$cwe_feed_ok"
export SECURITY_RESEARCH_TIER5_OK="$tier5_ok"
export SECURITY_RESEARCH_ASAN_OK="$asan_ok"
export SECURITY_RESEARCH_OVERALL_OK="$overall_ok"
export SECURITY_RESEARCH_GATE_LOG="$gate_log"
python3 - <<'PY'
import json
import os
from pathlib import Path

doc = {
    "generated_at": os.environ["SECURITY_RESEARCH_GRADE_STAMP"],
    "posture_ok": os.environ["SECURITY_RESEARCH_POSTURE_OK"] == "1",
    "cwe_feed_ok": os.environ["SECURITY_RESEARCH_CWE_FEED_OK"] == "1",
    "tier5_ok": os.environ["SECURITY_RESEARCH_TIER5_OK"] == "1",
    "asan_ok": os.environ["SECURITY_RESEARCH_ASAN_OK"] == "1",
    "study_only": os.environ.get("SECURITY_RESEARCH_STUDY_ONLY", "0") == "1",
    "overall_ok": os.environ["SECURITY_RESEARCH_OVERALL_OK"] == "1",
    "security_note": os.environ.get("SECURITY_RESEARCH_SECURITY_NOTE", "skip"),
    "gate_log": os.environ.get("SECURITY_RESEARCH_GATE_LOG", ""),
}
Path(os.environ["SECURITY_RESEARCH_GRADE_JSON"]).write_text(json.dumps(doc, indent=2) + "\n")
PY

if [[ "$overall_ok" -ne 1 ]]; then
  fail "hard gate failed (posture=$posture_ok cwe_feed=$cwe_feed_ok asan=$asan_ok) — see $GRADE_JSON"
fi
echo "security-research-gates: ok ($GRADE_JSON)"
