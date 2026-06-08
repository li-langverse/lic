#!/usr/bin/env bash
# CI-friendly gate: stiff ODE competitive JSON + ode_oracle.toml registry (ode-r2).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
RESULTS="${PH_SCI_ODE_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
OUT="$RESULTS/ph-sci-ode-oracle-competitive.json"

bash scripts/bench-ph-sci-ode-oracle-competitive.sh

[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }

python3 <<'PY'
import json
import sys
import tomllib
from pathlib import Path

out = Path("benchmarks/results/ph-sci-ode-oracle-competitive.json")
doc = json.loads(out.read_text())
rows = doc.get("rows") or []
if len(rows) < 2:
    print("expected >= 2 competitive rows")
    sys.exit(1)

ids = {r.get("id") for r in rows}
for want in ("stiff_ode_robertson", "stiff_ode_van_der_pol"):
    if want not in ids:
        print("missing row", want)
        sys.exit(1)

reg_path = Path("benchmarks/competitive/ode_oracle.toml")
if not reg_path.is_file():
    print("missing", reg_path)
    sys.exit(1)
reg = tomllib.loads(reg_path.read_text())
reg_ids = {r.get("id") for r in reg.get("row") or []}
for want in ("stiff_ode_robertson", "stiff_ode_van_der_pol"):
    if want not in reg_ids:
        print("ode_oracle.toml missing", want)
        sys.exit(1)
    row = next(r for r in reg["row"] if r["id"] == want)
    if not row.get("validity_required"):
        print(want, "must have validity_required=true")
        sys.exit(1)

for r in rows:
    if not r.get("validity_ok"):
        print("validity_ok false for", r.get("id"))
        sys.exit(1)

print("ph-sci-ode-oracle-competitive-gates OK")
PY
