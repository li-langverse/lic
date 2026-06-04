#!/usr/bin/env python3
"""Unit tests for swarm-gap-ingest plan_debt reconcile helpers."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INGEST = ROOT / "scripts/swarm-gap-ingest.py"


def _load_ingest():
    spec = importlib.util.spec_from_file_location("swarm_gap_ingest", INGEST)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def test_reopen_httpd_wrk_rows_when_plan_pending() -> None:
    mod = _load_ingest()
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": ["gap-phase2-perf-wrk-soak", "gap-phase2-streaming-wrk"],
                "state": {"completed_ids": []},
                "todos": [
                    {"id": "gap-phase2-perf-wrk-soak", "status": "pending"},
                    {"id": "gap-phase2-streaming-wrk", "status": "pending"},
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
            "evidence": ["deduped to canonical"],
        },
        "gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-streaming-wrk": {
            "id": "gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-streaming-wrk",
            "gap_kind": "plan_debt",
            "status": "closed",
            "runner_id": "httpd",
            "plan_todo_id": "gap-httpd-gap-httpd-gap-phase2-streaming-wrk",
            "evidence": [],
        },
    }
    reopened = mod.reconcile_plan_pending_open(snap, gaps)
    assert reopened == 2
    assert gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"] == "open"
    assert (
        gaps["gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-streaming-wrk"]["status"]
        == "open"
    )


def test_do_not_close_when_still_plan_pending() -> None:
    mod = _load_ingest()
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": ["gap-phase2-streaming-wrk"],
                "state": {"completed_ids": ["gap-phase2-streaming-wrk"]},
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
            "evidence": [],
        }
    }
    closed = mod.reconcile_snapshot_completed(snap, gaps)
    assert closed == 0
    assert gaps["gap-plan-pending-httpd-gap-phase2-streaming-wrk"]["status"] == "open"


def main() -> int:
    test_reopen_httpd_wrk_rows_when_plan_pending()
    test_do_not_close_when_still_plan_pending()
    print("test_swarm_gap_ingest_reconcile: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
