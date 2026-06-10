#!/usr/bin/env bash
# CI-friendly gate: md_oracle.toml registry + competitive JSON stub rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_MD_ORACLE_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-md-oracle-competitive.json"
REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"

[[ -f "$REGISTRY" ]] || { echo "missing $REGISTRY"; exit 1; }

bash scripts/bench-md-oracle-stub.sh
[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

registry = Path("benchmarks/competitive/md_oracle.toml")
doc = tomllib.loads(registry.read_text())
oracles = doc.get("oracle") or []
if len(oracles) < 2:
    print("md_oracle.toml must define lammps + gromacs oracles")
    sys.exit(1)
langs = {o.get("csv_lang") for o in oracles}
if langs != {"lammps", "gromacs"}:
    print("md_oracle.toml csv_lang must be lammps and gromacs, got", langs)
    sys.exit(1)

out = Path("benchmarks/results/ph-sci-md-oracle-competitive.json")
bench = json.loads(out.read_text())
rows = bench.get("rows") or []
if not rows:
    print("no competitive rows")
    sys.exit(1)
row = rows[0]
li = row.get("li") or {}
if li.get("checksum") is None or float(li["checksum"]) <= 0.0:
    print("missing positive Li MD oracle checksum")
    sys.exit(1)
comps = {c.get("id"): c for c in row.get("competitors") or []}
for cid in ("lammps", "gromacs"):
    c = comps.get(cid)
    if not c:
        print(f"missing competitor row {cid}")
        sys.exit(1)
    if c.get("status") != "stub":
        print(f"{cid} must be stub in v1")
        sys.exit(1)
    if c.get("csv_lang") != cid:
        print(f"{cid} csv_lang mismatch")
        sys.exit(1)

vert_path = Path("benchmarks/competitive/verticals.toml")
vert_doc = tomllib.loads(vert_path.read_text())
md_vert = next((v for v in vert_doc.get("vertical", []) if v.get("id") == "md_lennard_jones"), None)
if not md_vert:
    print("verticals.toml missing md_lennard_jones row")
    sys.exit(1)

print("ph-sci-md-oracle-gates OK")
PY
