#!/usr/bin/env python3
"""Unit checks for swarm-gap-ingest reconcile_snapshot_completed."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INGEST = ROOT / "scripts" / "swarm-gap-ingest.py"


def _load_ingest():
    spec = importlib.util.spec_from_file_location("swarm_gap_ingest", INGEST)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def test_todo_status_closes_plan_debt_when_completed_ids_empty() -> None:
    mod = _load_ingest()
    gaps = {
        "gap-plan-pending-sim-sim-p1-num-dot-axpy": {
            "id": "gap-plan-pending-sim-sim-p1-num-dot-axpy",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "sim",
            "plan_todo_id": "sim-p1-num-dot-axpy",
            "evidence": [],
        },
        "gap-plan-pending-sim-sim-p1-md-neighbor-cell": {
            "id": "gap-plan-pending-sim-sim-p1-md-neighbor-cell",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "sim",
            "plan_todo_id": "sim-p1-md-neighbor-cell",
            "evidence": [],
        },
    }
    snap = {
        "runners": [
            {
                "id": "sim",
                "state": {"completed_ids": []},
                "todos": [
                    {"id": "sim-p1-num-dot-axpy", "status": "completed"},
                    {"id": "sim-p1-md-neighbor-cell", "status": "done"},
                    {"id": "sim-p2-qm-dft-scf", "status": "pending"},
                ],
            }
        ]
    }
    closed = mod.reconcile_snapshot_completed(snap, gaps)
    assert closed == 2
    assert gaps["gap-plan-pending-sim-sim-p1-num-dot-axpy"]["status"] == "closed"
    assert gaps["gap-plan-pending-sim-sim-p1-md-neighbor-cell"]["status"] == "closed"


def test_completed_ids_still_closes_plan_debt() -> None:
    mod = _load_ingest()
    gaps = {
        "gap-plan-pending-studio-ui-ux-studio-ux-04": {
            "id": "gap-plan-pending-studio-ui-ux-studio-ux-04",
            "gap_kind": "plan_debt",
            "status": "open",
            "runner_id": "studio-ui-ux",
            "plan_todo_id": "studio-ux-04-particle-display",
            "evidence": [],
        }
    }
    snap = {
        "runners": [
            {
                "id": "studio-ui-ux",
                "state": {"completed_ids": ["studio-ux-04-particle-display"]},
                "todos": [{"id": "studio-ux-04-particle-display", "status": "pending"}],
            }
        ]
    }
    closed = mod.reconcile_snapshot_completed(snap, gaps)
    assert closed == 1
    assert gaps["gap-plan-pending-studio-ui-ux-studio-ux-04"]["status"] == "closed"


def main() -> int:
    tests = [
        test_todo_status_closes_plan_debt_when_completed_ids_empty,
        test_completed_ids_still_closes_plan_debt,
    ]
    for fn in tests:
        fn()
        print(f"ok {fn.__name__}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
