#!/usr/bin/env bash
# WP-PLAT-05 — LAMMPS/GROMACS external oracle stub driver for md_lennard_jones.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT"
exec python3 benchmarks/harness/md_external_oracle.py "$@"
