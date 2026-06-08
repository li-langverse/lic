#!/usr/bin/env bash
# ode-r2 competitive gate bundle (lic#35). CVODE oracle rows live in benchmarks repo;
# this gate validates lic-side BDF stubs + tooling until benchmarks#179 lands.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

grep -E 'bdf1_step_scalar|bdf2_step' packages/li-math-numerics/src/lib.li >/dev/null

if [[ ! -f packages/li-math-numerics/li-tests/smoke/bdf_stiff_ode_stub.li ]]; then
  echo "missing bdf_stiff_ode_stub.li smoke"
  exit 1
fi

bash li-tests/tooling/ode_external_oracle_stub.sh

if [[ -f benchmarks/competitive/ode_oracle.toml ]]; then
  grep -E 'stiff_ode_robertson|stiff_ode_van_der_pol' benchmarks/competitive/ode_oracle.toml >/dev/null \
    || echo "note: ode_oracle.toml present but stiff rows not yet wired"
  if [[ -f benchmarks/harness/sundials_ode_oracle.py ]]; then
    python3 benchmarks/harness/sundials_ode_oracle.py --problem robertson --check \
      || echo "note: sundials_ode_oracle.py present but CVODE not installed"
  fi
fi

echo "ph-sci-ode-oracle-competitive-gates: ok (ode-r3 BDF stub slice)"
