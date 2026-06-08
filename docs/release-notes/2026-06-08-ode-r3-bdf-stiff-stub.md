# ode-r3: BDF stiff ODE stubs (lic#35)

**Issue:** https://github.com/li-langverse/lic/issues/35  
**Plan:** `docs/superpowers/plans/2026-06-07-sundials-stiff-ode-sensitivity-plan.md`

## Summary

Adds fixed-step BDF-1/2 scalar and vec2 integrator stubs to `li-math-numerics` as the first shippable slice toward SUNDIALS-class stiff ODE credibility. CVODE oracle harness and tier-2 `stiff_ode_*` catalog rows remain in benchmarks#179.

## Verify

1. `bash scripts/ph-sci-ode-oracle-competitive-gates.sh` — exit 0
2. `bash li-tests/tooling/ode_external_oracle_stub.sh` — exit 0
3. `grep bdf1_step_scalar packages/li-math-numerics/src/lib.li`

## Paths

| Area | Path |
|------|------|
| Package | `packages/li-math-numerics/src/lib.li` |
| Smoke | `packages/li-math-numerics/li-tests/smoke/bdf_stiff_ode_stub.li` |
| Gates | `scripts/ph-sci-ode-oracle-competitive-gates.sh` |
| Proof-db | `docs/verification/proof-database/entries/num-ode-bdf1.toml` |
