#!/usr/bin/env bash
# Validate benchmarks/competitive/registry.toml and optional latest.csv columns.
# v1: stale last_reviewed warns only (LI_HPC_COMPETITIVE_STRICT=1 → exit 1 on stale).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

REGISTRY="$BENCHMARKS_COMPETITIVE/registry.toml"
CSV="${LI_HPC_COMPETITIVE_CSV:-$BENCHMARKS_RESULTS/latest.csv}"
STRICT="${LI_HPC_COMPETITIVE_STRICT:-0}"
WARN_DAYS="${LI_HPC_COMPETITIVE_REVIEW_DAYS:-90}"

li_phase "HPC competitive registry"
[[ -f "$REGISTRY" ]] || { li_fail "missing $REGISTRY"; exit 1; }

export REGISTRY CSV WARN_DAYS STRICT BENCHMARKS_ROOT
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from datetime import date, datetime
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

registry = Path(os.environ["REGISTRY"])
csv_path = Path(os.environ["CSV"])
warn_days = int(os.environ["WARN_DAYS"])
strict = os.environ.get("STRICT", "0") == "1"

data = tomllib.loads(registry.read_text())
required_eco = ("id", "track", "repo_url", "compare", "last_reviewed", "kernel_honesty")
valid_tracks = {"watch", "bench_tier0", "bench_tier1", "bench_tier2", "execution_resource_sweep"}
bench_langs: set[str] = set()
errors: list[str] = []
warnings: list[str] = []

ecos = data.get("ecosystem")
if not isinstance(ecos, list) or not ecos:
    errors.append("registry: [[ecosystem]] must be a non-empty array")

ids: set[str] = set()
for i, eco in enumerate(ecos or []):
    if not isinstance(eco, dict):
        errors.append(f"ecosystem[{i}]: not a table")
        continue
    for key in required_eco:
        if key not in eco:
            errors.append(f"{eco.get('id', i)}: missing field {key}")
    eid = eco.get("id", "")
    if eid in ids:
        errors.append(f"duplicate ecosystem id: {eid}")
    ids.add(eid)
    track = eco.get("track", "")
    if track not in valid_tracks:
        errors.append(f"{eid}: invalid track {track!r}")
    if track in ("bench_tier1", "bench_tier2"):
        lang = eco.get("csv_lang", "")
        if not lang:
            errors.append(f"{eid}: {track} requires csv_lang")
        else:
            bench_langs.add(lang)
    compare = eco.get("compare", [])
    if not isinstance(compare, list) or not compare:
        errors.append(f"{eid}: compare must be a non-empty array")
    lr = eco.get("last_reviewed", "")
    try:
        reviewed = date.fromisoformat(str(lr))
        age = (date.today() - reviewed).days
        if age > warn_days:
            msg = f"{eid}: last_reviewed {lr} is {age}d old (warn threshold {warn_days}d)"
            warnings.append(msg)
    except ValueError:
        errors.append(f"{eid}: last_reviewed must be YYYY-MM-DD, got {lr!r}")

if csv_path.is_file():
    import csv

    langs_in_csv: set[str] = set()
    with csv_path.open(newline="") as f:
        reader = csv.DictReader(f)
        if "lang" not in (reader.fieldnames or []):
            errors.append(f"{csv_path}: missing lang column")
        else:
            for row in reader:
                langs_in_csv.add(row.get("lang", ""))
    missing = sorted(bench_langs - langs_in_csv)
    if missing:
        bench_root = os.environ.get("BENCHMARKS_ROOT", "")
        warnings.append(
            f"latest.csv missing lang rows for bench ecosystems: {', '.join(missing)} "
            f"(run: {bench_root}/scripts/run-bench.sh --tier 12)"
        )
else:
    warnings.append(f"no CSV at {csv_path} — column check skipped")

for w in warnings:
    print(f"warn: {w}", file=sys.stderr)
for e in errors:
    print(f"error: {e}", file=sys.stderr)

if errors:
    sys.exit(1)
if strict and warnings:
    # Scheduled CI may set STRICT=1 to surface stale reviews; v1 default is warn-only.
    stale = [w for w in warnings if "last_reviewed" in w]
    if stale:
        sys.exit(1)
sys.exit(0)
PY
rc=$?
if [[ "$rc" -ne 0 ]]; then
  li_gate_fail "HPC competitive registry"
  exit "$rc"
fi
li_gate_ok "HPC competitive registry"

MD_ORACLE="$ROOT/benchmarks/competitive/md_oracle.toml"
if [[ -f "$MD_ORACLE" ]]; then
  li_phase "MD external oracle registry"
  export MD_ORACLE WARN_DAYS
  python3 - <<'PY'
from __future__ import annotations

import os
import sys
from datetime import date
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

path = Path(os.environ["MD_ORACLE"])
warn_days = int(os.environ["WARN_DAYS"])
data = tomllib.loads(path.read_text())
errors: list[str] = []
warnings: list[str] = []

meta = data.get("meta") or {}
if not meta.get("benchmark"):
    errors.append("md_oracle: meta.benchmark required")

oracles = data.get("oracle")
if not isinstance(oracles, list) or not oracles:
    errors.append("md_oracle: [[oracle]] must be a non-empty array")

ids: set[str] = set()
for o in oracles or []:
    oid = o.get("id")
    if not oid:
        errors.append("md_oracle: oracle id required")
        continue
    if oid in ids:
        errors.append(f"md_oracle: duplicate id {oid}")
    ids.add(oid)
    for key in ("csv_lang", "status", "kernel", "compare_metric"):
        if not o.get(key):
            errors.append(f"md_oracle: {oid} missing {key}")
    reviewed = o.get("last_reviewed") or meta.get("updated")
    if reviewed:
        try:
            age = (date.today() - date.fromisoformat(str(reviewed))).days
            if age > warn_days:
                warnings.append(f"md_oracle: {oid} last_reviewed {reviewed} ({age}d)")
        except ValueError:
            pass

rows = data.get("row")
if not isinstance(rows, list) or not rows:
    errors.append("md_oracle: [[row]] must be a non-empty array")

for w in warnings:
    print(f"warn: {w}", file=sys.stderr)
for e in errors:
    print(f"error: {e}", file=sys.stderr)
sys.exit(1 if errors else 0)
PY
  rc=$?
  if [[ "$rc" -ne 0 ]]; then
    li_gate_fail "MD external oracle registry"
    exit "$rc"
  fi
  li_gate_ok "MD external oracle registry"
fi
exit 0
