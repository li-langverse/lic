# md_oracle_external

Algo registry id **104** — external LAMMPS/GROMACS oracle column for tier-2 MD correctness.

**Oracle driver:** `benchmarks/harness/md_external_oracle.py`  
**Registry:** `benchmarks/competitive/md_oracle.toml`  
**Gate:** `scripts/ph-sci-md-oracle-competitive-gates.sh`  
**li-tests:** `li-tests/tooling/md_external_oracle_stub.sh`

Plan: `docs/superpowers/plans/2026-06-04-md-r3-oracle-plan.md` · Study: `docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md`

Status: **B0 stub** — records Li micro reference (`sim_scientific_oracle_checksum_md()`); LAMMPS/GROMACS binary parity deferred to B1/B2.
