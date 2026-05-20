#!/usr/bin/env bash
# Report tier-1/2 rows where Li wall_time / cpp wall_time exceeds threshold.
# Usage: ./scripts/benchmark-failures-report.sh [path/to/latest.csv]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CSV="${1:-$ROOT/benchmarks/results/latest.csv}"
THRESHOLD="${THRESHOLD_RATIO_CPP:-1.2}"

if [[ ! -f "$CSV" ]]; then
  echo "missing CSV: $CSV" >&2
  echo "hint: LIC=build/compiler/lic/lic python3 benchmarks/harness/bench.py --tier 12 --runs 3" >&2
  exit 1
fi

export CSV THRESHOLD ROOT
python3 - <<'PY'
import csv
import os
from pathlib import Path

csv_path = Path(os.environ["CSV"])
threshold = float(os.environ["THRESHOLD"])

rows = list(csv.DictReader(csv_path.open()))
by_bench: dict[str, dict[str, float]] = {}
for r in rows:
    if r.get("metric") != "wall_time":
        continue
    b = r["benchmark"]
    lang = r["lang"]
    by_bench.setdefault(b, {})[lang] = float(r["value"])

red, near, ok = [], [], []
for bench, langs in sorted(by_bench.items()):
    cpp = langs.get("cpp")
    li = langs.get("li")
    if cpp is None or li is None or cpp <= 0:
        continue
    ratio = li / cpp
    entry = (bench, ratio, li, cpp)
    if ratio > threshold:
        red.append(entry)
    elif ratio > 1.0:
        near.append(entry)
    else:
        ok.append(entry)

print(f"CSV: {csv_path}")
print(f"threshold_ratio_cpp: {threshold}")
print()
if red:
    print("RED (li/cpp > threshold):")
    for b, ratio, li, cpp in red:
        print(f"  {b}: ratio={ratio:.4f}  li={li:.4f}s  cpp={cpp:.4f}s")
else:
    print("RED: none")
print()
if near:
    print("NEAR-LIMIT (1.0 < li/cpp <= threshold):")
    for b, ratio, li, cpp in near:
        print(f"  {b}: ratio={ratio:.4f}  li={li:.4f}s  cpp={cpp:.4f}s")
else:
    print("NEAR-LIMIT: none")
print()
print(f"GREEN (li/cpp <= 1.0): {len(ok)} benches")
for b, ratio, _, _ in sorted(ok, key=lambda x: -x[1])[:8]:
    print(f"  {b}: ratio={ratio:.4f}")
PY
