#!/usr/bin/env python3
"""Merge manual UE5 baseline timings into world-engine comparison (optional).

Expected CSV columns:
  benchmark,subsystem,wall_time_ms,source,ue_version,notes

Example:
  game_world_soa_10k,ECS tick,1.8,UE Insights 5.4 sample,5.4,Empty level 10k actors

Writes: benchmarks/competitive/ue-baselines-merged.json
"""
from __future__ import annotations

import argparse
import csv
import json
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
PROXY = REPO / "benchmarks/competitive/unreal-proxy-targets.json"
WORLD = REPO / "benchmarks/competitive/world-engine-latest.json"
OUT = REPO / "benchmarks/competitive/ue-baselines-merged.json"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--csv", type=Path, required=True, help="Manual UE baseline CSV")
    args = parser.parse_args()

    proxy = json.loads(PROXY.read_text()) if PROXY.is_file() else {}
    world = json.loads(WORLD.read_text()) if WORLD.is_file() else {}
    ue_rows = list(csv.DictReader(args.csv.open()))

    merged = []
    for row in ue_rows:
        bid = row["benchmark"].strip()
        try:
            ue_ms = float(row["wall_time_ms"])
        except (TypeError, ValueError):
            continue
        li_full = world.get("full", {}).get(bid, {})
        li_ms = (li_full.get("li") or {}).get("s")
        li_ms = li_ms * 1000.0 if li_ms is not None else None
        merged.append(
            {
                "benchmark": bid,
                "ue_measured_ms": ue_ms,
                "li_measured_ms": round(li_ms, 4) if li_ms is not None else None,
                "li_vs_ue_ratio": round(li_ms / ue_ms, 4)
                if li_ms and ue_ms > 0
                else None,
                "ue_proxy_budget_ms": (proxy.get("targets", {}).get(bid, {}) or {}).get(
                    "aspirational_budget_ms_at_60fps"
                ),
                "source": row.get("source", ""),
                "ue_version": row.get("ue_version", ""),
            }
        )

    doc = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "disclaimer": "UE column is manual upload; Li column from world-engine-latest.json full scale.",
        "rows": merged,
    }
    OUT.write_text(json.dumps(doc, indent=2) + "\n")
    print(f"wrote {OUT} ({len(merged)} rows)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
