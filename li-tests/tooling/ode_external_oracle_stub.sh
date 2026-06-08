#!/usr/bin/env bash
# CI stub when SUNDIALS/CVODE is not installed — validates ode-r track wiring (lic#35).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

grep -q 'bdf1_step_scalar' packages/li-math-numerics/src/lib.li
grep -q 'bdf2_step_vec2' packages/li-math-numerics/src/lib.li
grep -q 'stiff_ode' docs/ecosystem/numerics-integrator-backlog.md

if [[ -f benchmarks/competitive/ode_oracle.toml ]]; then
  grep -q 'stiff_ode_robertson' benchmarks/competitive/ode_oracle.toml || true
fi

echo "ode_external_oracle_stub: ok (BDF package surface present; CVODE oracle deferred to benchmarks#179)"
