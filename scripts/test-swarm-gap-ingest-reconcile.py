#!/usr/bin/env python3
"""Smoke test for swarm-gap-ingest plan_pending ↔ registry reconcile."""
from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "swarm_gap_ingest", ROOT / "scripts/swarm-gap-ingest.py"
)
mod = importlib.util.module_from_spec(spec)
assert spec.loader
spec.loader.exec_module(mod)


def test_reopen_when_plan_pending() -> None:
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": ["gap-phase2-perf-wrk-soak"],
                "todos": [
                    {"id": "gap-phase2-perf-wrk-soak", "status": "pending"},
                ],
                "state": {"completed_ids": []},
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
        }
    }
    stats = mod.reconcile_snapshot_plan_state(snap, gaps)
    assert stats["reopened"] == 1
    assert gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"] == "open"


def test_close_when_completed_not_pending() -> None:
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": [],
                "todos": [
                    {"id": "gap-phase2-mitigation-exploits", "status": "completed"},
                ],
                "state": {"completed_ids": []},
            }
        ]
    }
    gaps = {
        "gap-plan-pending-httpd-gap-phase2-mitigation-exploits": {
            "id": "gap-plan-pending-httpd-gap-phase2-mitigation-exploits",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "httpd",
            "plan_todo_id": "gap-phase2-mitigation-exploits",
        }
    }
    stats = mod.reconcile_snapshot_plan_state(snap, gaps)
    assert stats["closed"] == 1
    assert gaps["gap-plan-pending-httpd-gap-phase2-mitigation-exploits"]["status"] == "closed"


def main() -> int:
    test_reopen_when_plan_pending()
    test_close_when_completed_not_pending()
    print("test-swarm-gap-ingest-reconcile: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
