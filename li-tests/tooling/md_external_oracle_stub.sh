#!/usr/bin/env bash
# Gate: md_lennard_jones external oracle stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
chmod +x "$ROOT/scripts/check-md-oracle-plan.sh"
"$ROOT/scripts/check-md-oracle-plan.sh"
echo "md_external_oracle_stub: ok"
