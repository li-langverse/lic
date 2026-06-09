#!/usr/bin/env python3
"""Unit checks for swarm-gap-ingest snapshot reconcile (#471 / #619)."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "swarm_gap_ingest", ROOT / "scripts/swarm-gap-ingest.py"
)
mod = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(mod)


def test_normalize_strips_runner_prefix() -> None:
    assert (
        mod._normalize_plan_todo_id("gap-httpd-gap-phase2-perf-wrk-soak", "httpd")
        == "gap-phase2-perf-wrk-soak"
    )


def test_reopen_closed_when_still_pending() -> None:
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": ["gap-phase2-perf-wrk-soak"],
                "todos": [
                    {"id": "gap-phase2-perf-wrk-soak", "status": "pending"},
                ],
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
    assert mod.reconcile_snapshot_pending(snap, gaps) == 1
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
    assert mod.reconcile_snapshot_completed(snap, gaps) == 1
    assert gaps["gap-plan-pending-httpd-gap-phase2-mitigation-exploits"]["status"] == "closed"


def test_no_close_while_pending() -> None:
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": ["gap-phase2-streaming-wrk"],
                "todos": [
                    {"id": "gap-phase2-streaming-wrk", "status": "completed"},
                ],
            }
        ]
    }
    gaps = {
        "gap-plan-pending-httpd-gap-phase2-streaming-wrk": {
            "id": "gap-plan-pending-httpd-gap-phase2-streaming-wrk",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "httpd",
            "plan_todo_id": "gap-phase2-streaming-wrk",
        }
    }
    assert mod.reconcile_snapshot_completed(snap, gaps) == 0
    assert gaps["gap-plan-pending-httpd-gap-phase2-streaming-wrk"]["status"] == "open"


def test_dedupe_keeps_short_canonical_id() -> None:
    gaps = {
        "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak": {
            "id": "gap-plan-pending-httpd-gap-phase2-perf-wrk-soak",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "httpd",
            "plan_todo_id": "gap-phase2-perf-wrk-soak",
        },
        "gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak": {
            "id": "gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "httpd",
            "plan_todo_id": "gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak",
        },
    }
    assert mod.dedupe_plan_pending_gaps(gaps) == 1
    assert gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"] == "open"
    assert (
        gaps["gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak"]["status"]
        == "closed"
    )


def main() -> int:
    tests = [
        test_normalize_strips_runner_prefix,
        test_reopen_closed_when_still_pending,
        test_close_when_completed_not_pending,
        test_no_close_while_pending,
        test_dedupe_keeps_short_canonical_id,
    ]
    for fn in tests:
        fn()
        print(f"ok {fn.__name__}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
