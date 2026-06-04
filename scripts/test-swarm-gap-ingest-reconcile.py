#!/usr/bin/env python3
"""Unit tests for swarm-gap-ingest snapshot reconcile (lic#619)."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INGEST = ROOT / "scripts" / "swarm-gap-ingest.py"
spec = importlib.util.spec_from_file_location("swarm_gap_ingest", INGEST)
ingest = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(ingest)


class ReconcileSnapshotPlanPending(unittest.TestCase):
    def test_reopens_closed_gap_when_plan_pending(self) -> None:
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
                "evidence": [],
            }
        }
        stats = ingest.reconcile_snapshot_plan_pending(snap, gaps)
        self.assertEqual(stats["opened"], 1)
        self.assertEqual(
            gaps["gap-plan-pending-httpd-gap-phase2-perf-wrk-soak"]["status"],
            "open",
        )

    def test_closes_open_gap_when_completed_not_pending(self) -> None:
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
                "evidence": [],
            }
        }
        stats = ingest.reconcile_snapshot_plan_pending(snap, gaps)
        self.assertEqual(stats["closed"], 1)
        self.assertEqual(
            gaps["gap-plan-pending-httpd-gap-phase2-mitigation-exploits"]["status"],
            "closed",
        )


if __name__ == "__main__":
    raise SystemExit(unittest.main())
