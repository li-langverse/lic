#!/usr/bin/env bash
# MD external oracle gate — registry + manifest + li-tests path citations (#523 / md-r3).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "md-oracle-competitive-gates: $*" >&2; exit 1; }

[[ -f "$ROOT/benchmarks/competitive/md_oracle.toml" ]] || fail "missing md_oracle.toml"
[[ -f "$ROOT/benchmarks/competitive/README-md-oracle.md" ]] || fail "missing README-md-oracle.md"
[[ -f "$ROOT/docs/benchmarks/competitive-engines-plan.md" ]] || fail "missing competitive-engines-plan.md"

# HPC registry (includes lammps/gromacs watch rows after this PR)
chmod +x "$ROOT/scripts/check-hpc-competitive.sh"
export LI_HPC_COMPETITIVE_STRICT="${LI_HPC_COMPETITIVE_STRICT:-0}"
"$ROOT/scripts/check-hpc-competitive.sh"

# Manifest cites oracle harness path
for f in \
  "$ROOT/packages/li-sim-scientific/li-tests/manifest.toml" \
  "$ROOT/li-tests/manifest.toml"; do
  [[ -f "$f" ]] || fail "missing $f"
  grep -qE 'md_external_oracle|md_oracle_external' "$f" || fail "$f missing md_external_oracle citation"
done

grep -q 'md_external_oracle.py' "$ROOT/benchmarks/competitive/README-md-oracle.md" \
  || fail "README-md-oracle.md must cite md_external_oracle.py"

[[ -f "$ROOT/packages/li-sim-scientific/li-tests/smoke/md_external_oracle_bench.li" ]] \
  || fail "missing md_external_oracle_bench.li"

python3 "$ROOT/scripts/md_external_oracle_stub.py" || fail "stub manifest failed"

[[ -f "$ROOT/benchmarks/results/md_lennard_jones/oracle_stub.json" ]] \
  || fail "missing oracle_stub.json"

python3 <<'PY'
import json
from pathlib import Path

doc = json.loads(Path("benchmarks/results/md_lennard_jones/oracle_stub.json").read_text())
if doc.get("catalog_id") != "md_oracle_external":
    raise SystemExit("oracle_stub.json: bad catalog_id")
if "lammps_lj_micro" not in (doc.get("oracle_ids") or []):
    raise SystemExit("oracle_stub.json: missing lammps_lj_micro")
print("md-oracle-competitive-gates: ok")
PY
