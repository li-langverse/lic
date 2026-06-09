#!/usr/bin/env bash
# Unit smoke for swarm-gap-ingest plan_pending reconcile (issue #619 / #436).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"

python3 - <<'PY'
import importlib.util
import sys
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "swarm_gap_ingest",
    Path("scripts/swarm-gap-ingest.py"),
)
mod = importlib.util.module_from_spec(spec)
sys.modules["swarm_gap_ingest"] = mod
spec.loader.exec_module(mod)

snap = {
    "runners": [
        {
            "id": "httpd",
            "plan_pending": ["gap-phase2-perf-wrk-soak", "gap-phase2-streaming-wrk"],
            "todos": [
                {"id": "gap-phase2-perf-wrk-soak", "status": "pending"},
                {"id": "gap-phase2-streaming-wrk", "status": "pending"},
                {"id": "gap-phase2-mitigation-exploits", "status": "completed"},
            ],
            "state": {"completed_ids": ["gap-phase2-mitigation-exploits"]},
        }
    ]
}

gaps = {
    "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak": {
        "id": "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak",
        "gap_kind": "plan_debt",
        "status": "closed",
        "runner_id": "httpd",
        "plan_todo_id": "gap-phase2-perf-wrk-soak",
        "evidence": ["deduped incorrectly"],
    },
    "gap-plan-pending-httpd-gap-phase2-mitigation-exploits": {
        "id": "gap-plan-pending-httpd-gap-phase2-mitigation-exploits",
        "gap_kind": "plan_debt",
        "status": "open",
        "runner_id": "httpd",
        "plan_todo_id": "gap-phase2-mitigation-exploits",
        "evidence": [],
    },
}

reopened = mod.reconcile_plan_pending_sync(snap, gaps)
assert reopened == 2, f"expected 2 status changes, got {reopened}"
assert gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"] == "open"
assert gaps["gap-plan-pending-httpd-gap-phase2-mitigation-exploits"]["status"] == "closed"

added = mod.ingest_snapshot_plan_pending(snap, gaps)
assert added == 1, f"expected 1 new row for streaming-wrk, got {added}"
stream_gid = "gap-plan-pending-httpd-gap-phase2-streaming-wrk"
assert gaps[stream_gid]["status"] == "open"

print("test-swarm-gap-ingest-reconcile: OK")
PY
