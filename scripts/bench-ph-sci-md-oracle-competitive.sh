#!/usr/bin/env bash
# PH-SCI MD external oracle competitive bench — Li micro oracle + LAMMPS/GROMACS stub manifest.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS/md_lennard_jones"

REGISTRY="$ROOT/benchmarks/competitive/md_oracle.toml"
OUT="$BENCHMARKS_RESULTS/md_lennard_jones/oracle_stub.json"
DRIVER="$ROOT/benchmarks/harness/md_external_oracle.py"

[[ -f "$REGISTRY" ]] || { echo "missing $REGISTRY"; exit 1; }
[[ -f "$DRIVER" ]] || { echo "missing $DRIVER"; exit 1; }

python3 "$DRIVER"
[[ -f "$OUT" ]] || { echo "missing $OUT"; exit 1; }
echo "bench-ph-sci-md-oracle-competitive: done ($OUT)"
