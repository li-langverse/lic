# Stiff ODE external oracle (ode-r2)

Compare **Li `li-math-numerics` BDF stubs** against CVODE/SUNDIALS reference solutions for stiff ODE workloads (lic#35).

## Run

```bash
# From lic repo root
bash scripts/ph-sci-ode-oracle-competitive-gates.sh
./li-tests/tooling/ode_external_oracle_stub.sh
```

Output: `benchmarks/results/ph-sci-ode-oracle-competitive.json`

## Methodology

| Problem | Stiffness | Ref tolerances | Oracle |
|---------|-----------|----------------|--------|
| Robertson (3-species) | High | rtol=1e-4, atol=1e-11 | CVODE BDF |
| Van der Pol (μ=1000) | Moderate–high | rtol=1e-6, atol=1e-8 | CVODE BDF |

## License notes

- **SUNDIALS/CVODE** — BSD-3-Clause; optional pip install for full oracle (`scipy`/`sundials` when available).
- CI stub path runs pinned reference JSON when SUNDIALS is not installed — see `ode_external_oracle_stub.sh`.

## Related

- Plan: `docs/superpowers/plans/2026-06-07-sundials-stiff-ode-sensitivity-plan.md`
- Registry: `benchmarks/competitive/ode_oracle.toml`
- benchmarks#179 — catalog ingest for tier-2 `stiff_ode_*` rows
