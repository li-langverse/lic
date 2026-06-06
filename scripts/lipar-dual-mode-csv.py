#!/usr/bin/env python3
"""Tag li benchmark rows as li_serial / li_parallel for dual-mode gates (WP-PAR-44)."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from copy import deepcopy
from pathlib import Path

CSV_HEADER = [
    "benchmark",
    "lang",
    "variant",
    "threads",
    "metric",
    "value",
    "stddev",
    "sample_runs",
    "unit",
    "git_sha",
    "cpu_model",
    "flags",
    "os",
    "passed",
    "oracle_kind",
    "verify_abs_err",
    "verify_rel_err",
    "verify_ulps",
    "verify_within_1ulp",
]

CLASS_A = frozenset({"matmul_blocked", "reduce_sum", "simd_dot", "num_dot_axpy"})
LI_MODES = frozenset({"li", "li_serial", "li_parallel"})
REGISTRY_ALIASES = {"num_dot_axpy": "simd_dot"}


def _read_csv(path: Path) -> list[dict[str, str]]:
    with path.open(newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def _write_csv(path: Path, rows: list[dict[str, str]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=CSV_HEADER, extrasaction="ignore")
        w.writeheader()
        for row in rows:
            w.writerow({k: row.get(k, "") for k in CSV_HEADER})


def _snapshot_path(csv_path: Path) -> Path:
    return csv_path.with_suffix(csv_path.suffix + ".lipar_serial.json")


def _tag_li_rows(rows: list[dict[str, str]], *, lang: str, variant: str, threads: str) -> list[dict[str, str]]:
    out: list[dict[str, str]] = []
    for row in rows:
        if row.get("benchmark") not in CLASS_A or row.get("lang") != "li":
            out.append(row)
            continue
        tagged = dict(row)
        tagged["lang"] = lang
        tagged["variant"] = variant
        tagged["threads"] = threads
        out.append(tagged)
    return out


def _drop_li_mode_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    return [
        row
        for row in rows
        if not (row.get("benchmark") in CLASS_A and row.get("lang") in LI_MODES)
    ]


def _alias_registry_rows(rows: list[dict[str, str]]) -> list[dict[str, str]]:
    extra: list[dict[str, str]] = []
    for alias, source in REGISTRY_ALIASES.items():
        if any(row.get("benchmark") == alias for row in rows):
            continue
        for row in rows:
            if row.get("benchmark") != source:
                continue
            cloned = deepcopy(row)
            cloned["benchmark"] = alias
            extra.append(cloned)
    return rows + extra


def serial_phase(csv_path: Path) -> None:
    rows = _read_csv(csv_path)
    tagged = _tag_li_rows(rows, lang="li_serial", variant="serial", threads="1")
    serial_rows = [row for row in tagged if row.get("lang") == "li_serial"]
    _snapshot_path(csv_path).write_text(json.dumps(serial_rows), encoding="utf-8")
    _write_csv(csv_path, tagged)
    print(f"lipar-dual-mode: tagged {len(serial_rows)} li_serial row(s) in {csv_path}")


def parallel_phase(csv_path: Path, *, cores: int) -> None:
    snap = _snapshot_path(csv_path)
    if not snap.is_file():
        print(f"lipar-dual-mode: missing serial snapshot {snap}", file=sys.stderr)
        sys.exit(1)
    serial_rows: list[dict[str, str]] = json.loads(snap.read_text(encoding="utf-8"))
    rows = _read_csv(csv_path)
    parallel_rows = _tag_li_rows(rows, lang="li_parallel", variant="parallel", threads=str(cores))
    parallel_rows = [row for row in parallel_rows if row.get("lang") == "li_parallel"]
    merged = _drop_li_mode_rows(rows)
    merged.extend(serial_rows)
    merged.extend(parallel_rows)
    merged = _alias_registry_rows(merged)
    _write_csv(csv_path, merged)
    snap.unlink(missing_ok=True)
    print(
        f"lipar-dual-mode: merged {len(serial_rows)} li_serial + "
        f"{len(parallel_rows)} li_parallel row(s) in {csv_path}"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--csv", type=Path, required=True)
    parser.add_argument("--mode", choices=("serial", "parallel"), required=True)
    parser.add_argument("--cores", type=int, default=8)
    args = parser.parse_args()
    if not args.csv.is_file():
        print(f"lipar-dual-mode: missing CSV {args.csv}", file=sys.stderr)
        return 1
    if args.mode == "serial":
        serial_phase(args.csv)
    else:
        parallel_phase(args.csv, cores=max(1, args.cores))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
