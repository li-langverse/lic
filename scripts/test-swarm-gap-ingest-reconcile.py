#!/usr/bin/env python3
"""Unit checks for swarm-gap-ingest snapshot reconcile helpers."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INGEST = ROOT / "scripts/swarm-gap-ingest.py"


def _load():
    spec = importlib.util.spec_from_file_location("swarm_gap_ingest", INGEST)
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(mod)
    return mod


def test_normalize_and_reconcile() -> None:
    mod = _load()
    rid = "httpd"
    norm = mod._normalize_plan_todo_id("gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak", rid)
    assert norm == "gap-phase2-perf-wrk-soak"

    gaps = {
        mod._canonical_plan_pending_gid(rid, norm): {
            "id": mod._canonical_plan_pending_gid(rid, norm),
            "gap_kind": "plan_debt",
            "status": "closed",
            "runner_id": rid,
            "plan_todo_id": norm,
            "evidence": [],
        }
    }
    snap = {
        "runners": [
            {
                "id": rid,
                "plan_pending": [norm],
                "todos": [{"id": norm, "status": "pending"}],
                "state": {"completed_ids": []},
            }
        ]
    }
    reopened = mod.reconcile_snapshot_pending(snap, gaps)
    assert reopened == 1
    assert gaps[mod._canonical_plan_pending_gid(rid, norm)]["status"] == "open"

    snap["runners"][0]["todos"][0]["status"] = "completed"
    snap["runners"][0]["plan_pending"] = []
    closed = mod.reconcile_snapshot_completed(snap, gaps)
    assert closed == 1
    assert gaps[mod._canonical_plan_pending_gid(rid, norm)]["status"] == "closed"


def main() -> int:
    test_normalize_and_reconcile()
    print("test-swarm-gap-ingest-reconcile: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
