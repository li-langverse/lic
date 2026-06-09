#!/usr/bin/env python3
"""Smoke tests for swarm-gap-ingest snapshot reconcile (lic#619)."""
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


def _gap(todo_id: str, *, status: str = "closed") -> dict:
    return {
        "id": f"gap-plan-pending-httpd-{mod._slug(todo_id)}",
        "gap_kind": "plan_debt",
        "status": status,
        "runner_id": "httpd",
        "plan_todo_id": todo_id,
        "evidence": [],
    }


def test_reopen_still_pending() -> None:
    snap = {
        "runners": [
            {
                "id": "httpd",
                "plan_pending": ["gap-phase2-perf-wrk-soak"],
                "todos": [
                    {"id": "gap-phase2-perf-wrk-soak", "status": "pending"},
                    {"id": "gap-phase2-mitigation-exploits", "status": "completed"},
                ],
                "state": {"completed_ids": []},
            }
        ]
    }
    gaps = {
        "wrk": _gap("gap-phase2-perf-wrk-soak"),
        "mit": _gap("gap-phase2-mitigation-exploits"),
    }
    n = mod.reconcile_snapshot_still_pending(snap, gaps)
    assert n == 1, n
    assert gaps["wrk"]["status"] == "open"
    assert gaps["mit"]["status"] == "closed"


def test_close_completed_not_pending() -> None:
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
    gaps = {"mit": _gap("gap-phase2-mitigation-exploits", status="open")}
    n = mod.reconcile_snapshot_completed(snap, gaps)
    assert n == 1, n
    assert gaps["mit"]["status"] == "closed"


def test_dedupe_prefers_clean_gid() -> None:
    clean = mod._canonical_plan_pending_gid(
        "httpd", "gap-phase2-perf-wrk-soak"
    )
    gaps = {
        clean: _gap("gap-phase2-perf-wrk-soak", status="open"),
        "dup": {
            **_gap("gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak", status="open"),
            "id": "gap-plan-pending-httpd-gap-httpd-gap-httpd-gap-phase2-perf-wrk-soak",
        },
    }
    n = mod.dedupe_plan_pending_gaps(gaps)
    assert n == 1, n
    assert gaps[clean]["status"] == "open"
    assert gaps["dup"]["status"] == "closed"


def main() -> int:
    test_reopen_still_pending()
    test_close_completed_not_pending()
    test_dedupe_prefers_clean_gid()
    print("check-swarm-gap-ingest-reconcile: OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
