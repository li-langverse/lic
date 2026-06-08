#!/usr/bin/env bash
# B0 external MD oracle bench — writes stub manifest (no LAMMPS/GROMACS required).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
exec python3 "$ROOT/scripts/md-external-oracle-stub.py" "$@"
