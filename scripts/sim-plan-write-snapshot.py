#!/usr/bin/env python3
"""Write data/sim-plan-loop/daily-snapshot.json for live canvas refresh."""
from __future__ import annotations

import csv
import json
import os
import subprocess
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SNAP = ROOT / "data/sim-plan-loop/daily-snapshot.json"
REGISTRY = ROOT / "benchmarks/competitive/algo_registry.json"
STATE = ROOT / "data/sim-plan-loop/state.json"
CSV_PATH = ROOT / "benchmarks/results/latest.csv"

FAMILIES = [
    "md",
    "pde",
    "rigid",
    "robo",
    "num",
    "qm",
    "drug",
    "bio",
    "ml",
    "am",
    "viz",
    "auto",
]


def process_running() -> bool:
    proc = subprocess.run(
        ["pgrep", "-af", "sim-plan-loop.py"],
        capture_output=True,
        text=True,
    )
    for line in (proc.stdout or "").splitlines():
        if "python3" in line and "pgrep" not in line:
            return True
    return False


def perf_rows(limit: int = 12) -> list[list[str]]:
    if not CSV_PATH.is_file():
        return []
    rows: list[list[str]] = []
    with CSV_PATH.open(encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            bench = row.get("benchmark", row.get("name", ""))
            if not bench or (
                "md_lennard_jones" not in bench
                and "heat_equation" not in bench
                and not bench.startswith("li,")
            ):
                continue
            rows.append(
                [
                    bench,
                    row.get("lang", row.get("language", "")),
                    row.get("metric", ""),
                    row.get("value", ""),
                    row.get("unit", ""),
                ]
            )
            if len(rows) >= limit:
                break
    return rows


def main() -> int:
    SNAP.parent.mkdir(parents=True, exist_ok=True)
    reg = json.loads(REGISTRY.read_text(encoding="utf-8"))
    algos = reg.get("algorithms") or []
    impl_by: dict[str, int] = defaultdict(int)
    rem_by: dict[str, int] = defaultdict(int)
    implemented = 0
    for a in algos:
        fam = a.get("family", "other")
        if a.get("implemented_smoke"):
            impl_by[fam] += 1
            implemented += 1
        else:
            rem_by[fam] += 1
    total = len(algos)
    state = json.loads(STATE.read_text(encoding="utf-8")) if STATE.is_file() else {}
    branch = subprocess.run(
        ["git", "-C", str(ROOT), "branch", "--show-current"],
        capture_output=True,
        text=True,
    ).stdout.strip() or "unknown"
    sha = subprocess.run(
        ["git", "-C", str(ROOT), "rev-parse", "--short", "HEAD"],
        capture_output=True,
        text=True,
    ).stdout.strip() or "unknown"

    snap = {
        "report_date": datetime.now().strftime("%Y-%m-%d"),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "tz": os.environ.get("TZ", os.environ.get("SIM_PLAN_TZ", "Europe/Berlin")),
        "branch": branch,
        "head": sha,
        "total_algos": total,
        "implemented": implemented,
        "remaining": total - implemented,
        "families": FAMILIES,
        "impl_by_family": {f: impl_by.get(f, 0) for f in FAMILIES},
        "rem_by_family": {f: rem_by.get(f, 0) for f in FAMILIES},
        "history": (state.get("history") or [])[-8:],
        "running": process_running(),
        "perf_rows": perf_rows(),
        "runner_log": "data/sim-plan-loop/runner.log",
    }
    SNAP.write_text(json.dumps(snap, indent=2) + "\n", encoding="utf-8")
    print(f"sim-plan-write-snapshot: {SNAP}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
