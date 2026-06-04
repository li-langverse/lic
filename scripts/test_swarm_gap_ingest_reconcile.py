#!/usr/bin/env python3
"""Unit tests for swarm-gap-ingest plan_pending / completed reconciliation."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "swarm_gap_ingest",
    ROOT / "scripts/swarm-gap-ingest.py",
)
ingest = importlib.util.module_from_spec(spec)
sys.modules["swarm_gap_ingest"] = ingest
assert spec.loader is not None
spec.loader.exec_module(ingest)


def _httpd_runner(*, pending: list[str], completed_todos: list[str]) -> dict:
    todos = [
        {"id": tid, "status": "completed"} for tid in completed_todos
    ] + [{"id": tid, "status": "pending"} for tid in pending]
    return {
        "id": "httpd",
        "plan_pending": pending,
        "todos": todos,
        "state": {"completed_ids": []},
    }


def test_reopen_closed_gap_when_plan_pending_returns() -> None:
    snap = {"runners": [_httpd_runner(pending=["gap-phase2-perf-wrk-soak"], completed_todos=[])]}
    gaps = {
        "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak": {
            "id": "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak",
            "gap_kind": "plan_debt",
            "status": "closed",
            "runner_id": "httpd",
            "plan_todo_id": "gap-phase2-perf-wrk-soak",
            "evidence": [],
        }
    }
    ingest.ingest_snapshot_plan_pending(snap, gaps)
    assert gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"] == "open"


def test_close_gap_when_todo_completed_not_pending() -> None:
    snap = {
        "runners": [
            _httpd_runner(
                pending=[],
                completed_todos=["gap-phase2-streaming-wrk"],
            )
        ]
    }
    gaps = {
        "gap-plan-pending-httpd-gap-phase2-streaming-wrk": {
            "id": "gap-plan-pending-httpd-gap-phase2-streaming-wrk",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "httpd",
            "plan_todo_id": "gap-phase2-streaming-wrk",
            "evidence": [],
        }
    }
    closed = ingest.reconcile_snapshot_completed(snap, gaps)
    assert closed == 1
    assert gaps["gap-plan-pending-httpd-gap-phase2-streaming-wrk"]["status"] == "closed"


def test_pending_blocks_close_even_if_in_completed_ids() -> None:
    runner = _httpd_runner(
        pending=["gap-phase2-perf-wrk-soak"],
        completed_todos=["gap-phase2-perf-wrk-soak"],
    )
    runner["state"]["completed_ids"] = ["gap-phase2-perf-wrk-soak"]
    snap = {"runners": [runner]}
    gaps = {
        "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak": {
            "id": "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "httpd",
            "plan_todo_id": "gap-phase2-perf-wrk-soak",
            "evidence": [],
        }
    }
    assert ingest.reconcile_snapshot_completed(snap, gaps) == 0
    assert gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"] == "open"


def main() -> int:
    test_reopen_closed_gap_when_plan_pending_returns()
    test_close_gap_when_todo_completed_not_pending()
    test_pending_blocks_close_even_if_in_completed_ids()
    print("test_swarm_gap_ingest_reconcile: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
