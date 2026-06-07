#!/usr/bin/env python3
"""WP-PAR-02 — merge tier shard CSVs into latest.csv after full org suite run.

run-full-benchmark-suite.sh writes perf wall_time rows to tier-tier*.csv shards while
tier-5 HTTP/exploit ingest can leave results/latest.csv without wall_time. Killer gate
step 3 and lipar-dual-mode-csv need the merged CSV.
"""

from __future__ import annotations

import csv
import subprocess
import sys
from pathlib import Path


def _wall_time_count(path: Path) -> int:
    if not path.is_file():
        return 0
    with path.open(newline="", encoding="utf-8") as f:
        return sum(1 for row in csv.DictReader(f) if row.get("metric") == "wall_time")


def _tier_shards(results_dir: Path) -> list[Path]:
    shards: list[Path] = []
    for pattern in ("tier-tier*.csv", "tier-[0-9]*.csv", "latest-lic-bench.csv"):
        for path in sorted(results_dir.glob(pattern)):
            if path.name == "latest.csv":
                continue
            if path.name == "tier-tier5-exploits.csv":
                continue
            if path not in shards:
                shards.append(path)
    return shards


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: lipar-merge-tier-csv.py <benchmarks-root>", file=sys.stderr)
        return 2

    bench_root = Path(sys.argv[1]).resolve()
    results = bench_root / "results"
    latest = results / "latest.csv"
    if not results.is_dir():
        print(f"lipar-merge-tier-csv: missing {results}", file=sys.stderr)
        return 1

    shards = _tier_shards(results)
    if not shards:
        print(f"lipar-merge-tier-csv: no tier shard CSVs under {results}", file=sys.stderr)
        return 1

    merge_py = bench_root / "scripts/ingest/merge_bench_csv_artifacts.py"
    if merge_py.is_file():
        inputs = [str(p) for p in shards]
        if latest.is_file():
            inputs.append(str(latest))
        cmd = [sys.executable, str(merge_py), str(latest), *inputs]
        subprocess.run(cmd, check=True)
    else:
        # Fallback when benchmarks checkout lacks merge helper (unit tests).
        header: list[str] | None = None
        rows: list[dict[str, str]] = []
        key_cols = ("benchmark", "lang", "variant", "metric", "os")
        index: dict[tuple[str, ...], int] = {}
        for path in [*shards, *( [latest] if latest.is_file() else [] )]:
            with path.open(newline="", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                if not reader.fieldnames:
                    continue
                if header is None:
                    header = list(reader.fieldnames)
                for row in reader:
                    key = tuple(row.get(c, "") for c in key_cols)
                    normalized = {c: row.get(c, "") for c in header}
                    if key in index:
                        rows[index[key]] = normalized
                    else:
                        index[key] = len(rows)
                        rows.append(normalized)
        if not header:
            print("lipar-merge-tier-csv: no CSV header in shards", file=sys.stderr)
            return 1
        latest.parent.mkdir(parents=True, exist_ok=True)
        with latest.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=header, extrasaction="ignore")
            writer.writeheader()
            writer.writerows(rows)

    wall = _wall_time_count(latest)
    min_rows = int(__import__("os").environ.get("LIPAR_MERGE_MIN_WALL", "80"))
    print(
        f"lipar-merge-tier-csv: merged {len(shards)} shard(s) into {latest} "
        f"(wall_time rows={wall})"
    )
    if wall < min_rows:
        print(
            f"lipar-merge-tier-csv: WARN wall_time rows {wall} < {min_rows}",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
