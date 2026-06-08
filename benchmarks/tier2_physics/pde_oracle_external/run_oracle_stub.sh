#!/usr/bin/env bash
# External PDE oracle stub (PETSc+hypre columns). See docs/benchmarks/competitive-pde-engines-plan.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
exec python3 "$ROOT/benchmarks/harness/pde_external_oracle.py" "$@"
