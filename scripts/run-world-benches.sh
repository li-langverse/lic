#!/usr/bin/env bash
# Timed world_engine + gaming_full kernels (competitive gaming path).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RUNS="${LI_BENCH_RUNS:-3}"
ONLY="${LI_BENCH_ONLY:-game_world_soa_10k,game_replication_encode,sim_physics_frame,cloth_swing,rigid_body_stack}"
QUICK_OUT="${LI_BENCH_CSV_QUICK:-$ROOT/benchmarks/results/world_engine_quick.csv}"
FULL_OUT="${LI_BENCH_CSV_FULL:-$ROOT/benchmarks/results/world_engine_full.csv}"
SUMMARY="$ROOT/benchmarks/competitive/world-engine-latest.json"

bench_once() {
  local scale_flag="$1"
  local out="$2"
  python3 benchmarks/harness/bench.py --tier 2 $scale_flag --runs "$RUNS" \
    --only "$ONLY" --skip-validity --out "$out"
}

echo "== world_engine + gaming_full (only=${ONLY}) runs=${RUNS} =="
export LI_BENCH_QUICK=1
bench_once --quick "$QUICK_OUT"
export LI_BENCH_QUICK=0
bench_once --full "$FULL_OUT"

python3 benchmarks/harness/validity.py --tier 2 --quick 2>&1 \
  | rg 'game_world|game_replication|sim_physics|cloth_swing|rigid_body_stack|wrote' || true

export LI_BENCH_ONLY="$ONLY"
export LI_BENCH_SUMMARY="$SUMMARY"
python3 - <<'PY'
import csv
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(os.environ["LI_BENCH_SUMMARY"]).resolve().parents[2]
ONLY = [x.strip() for x in os.environ.get("LI_BENCH_ONLY", "").split(",") if x.strip()]
SUMMARY = Path(os.environ["LI_BENCH_SUMMARY"])


def load(path: Path):
    if not path.exists():
        return []
    return list(csv.DictReader(path.open()))


def wall(rows, bench, lang):
    for r in rows:
        if r.get("benchmark") == bench and r.get("lang") == lang and r.get("metric") == "wall_time":
            return {"s": float(r["value"]), "stdev": r.get("value_stdev") or ""}
    return None


def scale_block(path: Path, scale: str):
    rows = load(path)
    benches = {}
    for b in ONLY:
        if b.startswith("game_") or b == "sim_physics_frame":
            wc = "world_engine"
        elif scale == "full":
            wc = "gaming_full"
        else:
            wc = "v0_gaming"
        entry = {"workload_class": wc}
        for lang in ("cpp", "rust", "julia", "li"):
            t = wall(rows, b, lang)
            if t:
                entry[lang] = t
        if len(entry) > 1:
            benches[b] = entry
    return benches


doc = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "git_sha": subprocess.check_output(
        ["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, text=True
    ).strip(),
    "quick": scale_block(ROOT / "benchmarks/results/world_engine_quick.csv", "quick"),
    "full": scale_block(ROOT / "benchmarks/results/world_engine_full.csv", "full"),
    "notes": "Not UE parity — timed C/Li shared kernels; Li sim_step_physics body still stub.",
}
SUMMARY.write_text(json.dumps(doc, indent=2) + "\n")
print(f"wrote {SUMMARY}")
PY

echo "done: $QUICK_OUT $FULL_OUT $SUMMARY"
