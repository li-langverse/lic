#!/usr/bin/env bash
# WP-PAR-40–43 — li-parallel perf gate: speedup vs li_serial + li_parallel vs C++ (OpenMP proxy).
# Advisory by default; set LI_LIPAR_PERF_STRICT=1 to fail CI on gaps.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

CSV="${LI_LIPAR_PERF_CSV:-${BENCHMARKS_CSV:-$BENCHMARKS_RESULTS/latest.csv}}"
STRICT="${LI_LIPAR_PERF_STRICT:-0}"
MIN_SPEEDUP="${LI_LIPAR_MIN_SPEEDUP:-1.05}"
MIN_WALL="${LI_LIPAR_MIN_WALL_SEC:-0.005}"
MAX_VS_CPP="${LI_LIPAR_MAX_VS_CPP:-1.2}"

li_phase "li-parallel perf (min speedup ${MIN_SPEEDUP}×, max vs cpp ${MAX_VS_CPP}×, strict=${STRICT})"

[[ -f "$CSV" ]] || {
  li_fail "missing $CSV — run lipar-suite --dual-mode or set LI_LIPAR_PERF_CSV"
  exit 1
}

export CSV MIN_SPEEDUP MIN_WALL MAX_VS_CPP STRICT
python3 - <<'PY'
from __future__ import annotations

import csv
import os
import sys
from pathlib import Path

csv_path = Path(os.environ["CSV"])
min_speedup = float(os.environ["MIN_SPEEDUP"])
min_wall = float(os.environ["MIN_WALL"])
max_vs_cpp = float(os.environ["MAX_VS_CPP"])
strict = os.environ.get("STRICT", "0") == "1"

# Class A tier1 dual-mode rows (WP-PAR-45).
benches = ("matmul_blocked", "reduce_sum", "simd_dot", "num_dot_axpy")
# simd_dot / num_dot_axpy are SIMD intrathread (registry: parallelism=simd_intrathread).
# Dual-mode rows are required; thread-pool speedup is not expected.
SIMD_INTRATHREAD = frozenset({"simd_dot", "num_dot_axpy"})

rows: dict[tuple[str, str], float] = {}
with csv_path.open(newline="", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        if row.get("metric") != "wall_time":
            continue
        key = (row["benchmark"], row["lang"])
        rows[key] = float(row["value"])

speed_gaps: list[str] = []
cpp_gaps: list[str] = []
skipped: list[str] = []
ok_lines: list[str] = []
errors: list[str] = []

for bench in benches:
    serial = rows.get((bench, "li_serial"))
    parallel = rows.get((bench, "li_parallel"))
    cpp = rows.get((bench, "cpp"))

    if serial is None or parallel is None:
        errors.append(f"{bench}: missing li_serial or li_parallel wall_time")
        continue
    if serial <= 0 or parallel <= 0:
        errors.append(f"{bench}: invalid wall_time serial={serial} parallel={parallel}")
        continue

    speedup = serial / parallel
    speed_line = (
        f"{bench}: serial={serial:.6f}s parallel={parallel:.6f}s "
        f"speedup={speedup:.3f}× (min {min_speedup}× when serial≥{min_wall}s)"
    )
    if bench in SIMD_INTRATHREAD:
        skipped.append(
            f"SKIP {speed_line} — simd_intrathread (no thread-pool speedup expected)"
        )
    elif serial < min_wall:
        skipped.append(f"SKIP {speed_line}")
    elif speedup < min_speedup:
        speed_gaps.append(f"GAP {speed_line}")
    else:
        ok_lines.append(f"OK  {speed_line}")

    if cpp is None or cpp <= 0:
        skipped.append(f"SKIP {bench}: no cpp wall_time for OpenMP proxy")
        continue
    ratio = parallel / cpp
    cpp_line = (
        f"{bench}: li_parallel={parallel:.6f}s cpp={cpp:.6f}s "
        f"ratio={ratio:.3f}× (cap {max_vs_cpp}×)"
    )
    if bench in SIMD_INTRATHREAD:
        skipped.append(
            f"SKIP {cpp_line} — simd_intrathread (parallel pass is tagging only)"
        )
    elif ratio > max_vs_cpp:
        cpp_gaps.append(f"GAP {cpp_line}")
    else:
        ok_lines.append(f"OK  {cpp_line}")

print("li_parallel_perf: speedup vs li_serial:")
for line in ok_lines:
    if "speedup=" in line:
        print(f"  {line}")
for line in skipped:
    if "speedup=" in line:
        print(f"  {line}")
if speed_gaps:
    print("li_parallel_perf: SPEEDUP GAPS:")
    for line in speed_gaps:
        print(f"  {line}")

print("li_parallel_perf: li_parallel vs cpp:")
for line in ok_lines:
    if "li_parallel=" in line and "cpp=" in line:
        print(f"  {line}")
if cpp_gaps:
    print("li_parallel_perf: VS-CPP GAPS:")
    for line in cpp_gaps:
        print(f"  {line}")

if errors:
    for e in errors:
        print(f"li_parallel_perf: ERROR {e}", file=sys.stderr)
    sys.exit(1)

gaps = speed_gaps + cpp_gaps
if gaps and strict:
    print(
        f"li_parallel_perf: FAIL strict mode ({len(gaps)} gap(s))",
        file=sys.stderr,
    )
    sys.exit(1)

if gaps:
    print(
        f"li_parallel_perf: advisory — {len(gaps)} gap(s); "
        "set LI_LIPAR_PERF_STRICT=1 to fail CI"
    )
else:
    print("li_parallel_perf: all Class A tier1 benches within thresholds")
PY

li_ok "li_parallel_perf check finished"
