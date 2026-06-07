#!/usr/bin/env bash
# WP-PAR-02 — tier shard CSVs restore wall_time rows into latest.csv for killer gate.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

cache="$ROOT/.cache/li-benchmarks"
if [[ ! -f "$cache/results/tier-tier1.csv" ]]; then
  mkdir -p "$(dirname "$cache")"
  git clone --depth 1 https://github.com/li-langverse/benchmarks.git "$cache" >/dev/null 2>&1 || true
fi

# Simulate post-suite latest.csv with only tier-5 HTTP/exploit rows (no wall_time).
cat >"$cache/results/latest.csv" <<'CSV'
benchmark,lang,variant,threads,metric,value,stddev,sample_runs,unit,git_sha,cpu_model,flags,os,passed,oracle_kind,verify_abs_err,verify_rel_err,verify_ulps,verify_within_1ulp
exploit_slowloris,li,exploit,1,pass,1,,1,,test,,pass,linux,1,,,,,
static_small,nginx,release,4,rps,100,,,req/s,test,x86_64,wrk,,,,,,,
CSV

export LIPAR_MERGE_MIN_WALL=80
python3 "$ROOT/scripts/lipar-merge-tier-csv.py" "$cache"

python3 - "$cache/results/latest.csv" <<'PY'
import csv
import sys

path = sys.argv[1]
rows = list(csv.DictReader(open(path, newline="", encoding="utf-8")))
wall = [r for r in rows if r.get("metric") == "wall_time"]
li_wall = [r for r in wall if r.get("lang") == "li"]
if len(wall) < 80:
    print(f"li_parallel_merge_tier_csv: expected >=80 wall_time rows, got {len(wall)}", file=sys.stderr)
    sys.exit(1)
if not li_wall:
    print("li_parallel_merge_tier_csv: missing li wall_time rows", file=sys.stderr)
    sys.exit(1)
print(f"li_parallel_merge_tier_csv: ok ({len(wall)} wall_time, {len(li_wall)} li)")
PY
