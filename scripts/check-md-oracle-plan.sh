#!/usr/bin/env bash
# CI gate: md_oracle.toml registry + external oracle stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ORACLE_TOML="$ROOT/benchmarks/competitive/md_oracle.toml"
STUB="$ROOT/benchmarks/tier2_physics/md_lennard_jones/external/run_oracle_stub.sh"
MANIFEST="$ROOT/benchmarks/results/md_lennard_jones/oracle_stub.json"

[[ -f "$ORACLE_TOML" ]] || { echo "check-md-oracle-plan: missing $ORACLE_TOML" >&2; exit 1; }
[[ -f "$STUB" ]] || { echo "check-md-oracle-plan: missing $STUB" >&2; exit 1; }

python3 - <<'PY' "$ORACLE_TOML"
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

path = Path(sys.argv[1])
data = tomllib.loads(path.read_text())
meta = data.get("meta") or {}
if meta.get("benchmark") != "md_lennard_jones":
    raise SystemExit("meta.benchmark must be md_lennard_jones")
oracles = data.get("oracle") or []
ids = {o.get("id") for o in oracles if isinstance(o, dict)}
for required in ("lammps_lj_micro", "gromacs_lj_micro"):
    if required not in ids:
        raise SystemExit(f"missing oracle id {required}")
print("md_oracle.toml: ok")
PY

chmod +x "$STUB"
"$STUB"

[[ -f "$MANIFEST" ]] || { echo "check-md-oracle-plan: missing $MANIFEST" >&2; exit 1; }

python3 - <<'PY' "$MANIFEST" "$ORACLE_TOML"
import json
import sys
from pathlib import Path

manifest = Path(sys.argv[1])
oracle_toml = Path(sys.argv[2])
data = json.loads(manifest.read_text())
if data.get("mode") != "stub_ok":
    raise SystemExit(f"unexpected mode: {data.get('mode')}")
drift = data.get("reference_energy_drift")
if drift is None or float(drift) <= 0.0:
    raise SystemExit("missing positive reference_energy_drift")
ids = data.get("oracle_ids") or []
for required in ("lammps_lj_micro", "gromacs_lj_micro"):
    if required not in ids:
        raise SystemExit(f"manifest missing oracle id {required}")
reg_path = data.get("oracle_registry", "")
if not reg_path.endswith("md_oracle.toml"):
    raise SystemExit(f"manifest oracle_registry must cite md_oracle.toml, got {reg_path!r}")
if Path(reg_path).name != oracle_toml.name:
    raise SystemExit("manifest oracle_registry path mismatch")
print("oracle_stub.json: ok drift=", drift)
PY

echo "check-md-oracle-plan: ok"
