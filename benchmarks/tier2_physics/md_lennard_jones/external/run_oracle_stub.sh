#!/usr/bin/env bash
# External MD oracle stub (LAMMPS/GROMACS columns). See docs/benchmarks/competitive-engines-plan.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
exec python3 "$ROOT/benchmarks/harness/md_external_oracle.py" "$@"
