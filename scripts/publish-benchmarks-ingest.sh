#!/usr/bin/env bash
# Run world/gaming benches, export CSV for org benchmarks ingest, optional push to BENCHMARKS_ROOT.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$(cd "$ROOT/.." && pwd)}"
RUNS="${LI_BENCH_RUNS:-3}"

echo "== 1/4 timed world_engine + gaming_full =="
./scripts/run-world-benches.sh

INGEST_CSV="$ROOT/benchmarks/results/ingest_world_gaming.csv"
echo "== 2/4 merge into ingest CSV =="
python3 <<PY
import csv
from pathlib import Path

ROOT = Path("$ROOT")
parts = [
    ROOT / "benchmarks/results/world_engine_full.csv",
    ROOT / "benchmarks/results/world_engine_quick.csv",
]
rows = []
seen = set()
for p in parts:
    if not p.exists():
        continue
    for r in csv.DictReader(p.open()):
        key = (r["benchmark"], r["lang"], r.get("metric", "wall_time"))
        if key in seen and p.name.endswith("quick.csv"):
            continue
        seen.add(key)
        r = dict(r)
        r["scale"] = "full" if "full" in p.name else "quick"
        rows.append(r)

out = ROOT / "benchmarks/results/ingest_world_gaming.csv"
if rows:
    with out.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"wrote {out} ({len(rows)} rows)")
PY

echo "== 3/4 patch latest.csv (world rows from full scale) =="
export LIC_REPO_ROOT="$ROOT"
python3 <<'PY'
import csv
import os
from pathlib import Path

ROOT = Path(os.environ["LIC_REPO_ROOT"])
latest = ROOT / "benchmarks/results/latest.csv"
ingest = ROOT / "benchmarks/results/ingest_world_gaming.csv"
WORLD = {
    "game_world_soa_10k",
    "game_replication_encode",
    "sim_physics_frame",
    "render_frame_present",
    "cloth_swing",
    "rigid_body_stack",
}

def load(p):
    if not p.exists():
        return []
    return list(csv.DictReader(p.open()))

existing = load(latest)
ing = [r for r in load(ingest) if r.get("scale") == "full"]
if not ing:
    print("skip latest patch (no ingest rows)")
else:
    kept = [r for r in existing if r.get("benchmark") not in WORLD]
    merged = kept + ing
    fields = list({k for r in merged for k in r})
    with latest.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(merged)
    print(f"updated {latest} ({len(merged)} rows)")
PY

if [[ -d "$BENCHMARKS_ROOT/scripts/ingest" ]]; then
  echo "== 4/4 org benchmarks ingest (BENCHMARKS_ROOT=$BENCHMARKS_ROOT) =="
  cp -f "$ROOT/benchmarks/competitive/world-engine-latest.json" \
    "$BENCHMARKS_ROOT/data/incoming/world-engine-latest.json" 2>/dev/null || \
    mkdir -p "$BENCHMARKS_ROOT/data/incoming" && \
    cp -f "$ROOT/benchmarks/competitive/world-engine-latest.json" \
      "$BENCHMARKS_ROOT/data/incoming/world-engine-latest.json"
  cp -f "$ROOT/benchmarks/competitive/unreal-proxy-targets.json" \
    "$BENCHMARKS_ROOT/data/incoming/unreal-proxy-targets.json" 2>/dev/null || true
  cp -f "$ROOT/benchmarks/competitive/engines.toml" \
    "$BENCHMARKS_ROOT/data/incoming/engines.toml" 2>/dev/null || true
  _LIS="${LIS_ROOT:-$BENCHMARKS_ROOT/../lis}"
  LIC_ROOT="$ROOT" python3 "$BENCHMARKS_ROOT/scripts/ingest/build_summary.py" "$ROOT" "$_LIS" || true
  LIC_ROOT="$ROOT" python3 "$BENCHMARKS_ROOT/scripts/generate_competitive_status.py" "$ROOT" || true
  echo "ingest complete (see $BENCHMARKS_ROOT/data/latest/)"
else
  echo "== 4/4 skip org ingest (no benchmarks repo at $BENCHMARKS_ROOT)"
fi
