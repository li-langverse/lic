#!/usr/bin/env bash
# CI stub when SUNDIALS/CVODE is not installed — checks pinned registry + JSON honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

grep -q 'stiff_ode_robertson' benchmarks/competitive/ode_oracle.toml
grep -q 'stiff_ode_van_der_pol' benchmarks/competitive/ode_oracle.toml
grep -q 'bdf1_step_scalar' packages/li-math-numerics/src/lib.li
grep -q 'bdf2_step_vec2' packages/li-math-numerics/src/lib.li

bash scripts/ph-sci-ode-oracle-competitive-gates.sh

echo "ode_external_oracle_stub: ok"
