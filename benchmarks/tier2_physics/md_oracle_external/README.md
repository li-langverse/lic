# md_oracle_external (algo_registry id 104)

**Catalog path:** `benchmarks/tier2_physics/md_oracle_external`  
**Oracle driver:** `benchmarks/harness/md_external_oracle.py`  
**Registry:** `benchmarks/competitive/md_oracle.toml`  
**Plan:** `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md`

External LAMMPS/GROMACS oracle column for tier-2 MD correctness (PH-5b / G-math). Tier-0 Li↔C parity remains in `md_lennard_jones`; this bench adds **Layer B** domain-engine honesty.

## Oracle tiers

| Tier | Engine | Role |
|------|--------|------|
| T0 | Shared C (`md_core.c`) | Cross-lang reference (existing green) |
| T1 | Li composable (`scientific_oracle_bench.li`) | Package smoke checksum |
| T2 | LAMMPS / GROMACS micro | External force/energy oracle (optional profile) |

## Gate commands

```bash
# Stub manifest (no LAMMPS/GROMACS required)
python3 benchmarks/harness/md_external_oracle.py --engine lammps --dry-run

# li-tests tooling gate
./li-tests/tooling/md_external_oracle_stub.sh

# Research study gate
SIM_RESEARCH_VERTICAL=md SIM_RESEARCH_BACKLOG_STUDY_ONLY=1 \
  SIM_RESEARCH_REQUIRE_STUDY=docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md \
  ./scripts/sim-algo-research-gates.sh
```

## Pinned versions

See `benchmarks/competitive/md_oracle.toml` — LAMMPS `stable_22Jun2024`, GROMACS `v2024.2`. No floating `apt install lammps`.

## Status

**B0 stub** — records native reference when tier-2 tree exists; dry-run mode for CI without full harness checkout.
