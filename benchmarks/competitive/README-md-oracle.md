# MD external oracle competitive benchmark (WP-PLAT-05)

Compare **Li `sim_scientific_oracle_checksum_md()`** (4-particle LJ chain, 8 velocity-Verlet steps) against LAMMPS/GROMACS domain oracle columns.

## Run

```bash
bash scripts/bench-ph-sci-md-oracle-competitive.sh
bash scripts/ph-sci-md-oracle-competitive-gates.sh
```

Output: `benchmarks/results/ph-sci-md-oracle-competitive.json`

## Methodology

| Field | Value |
|-------|-------|
| Workload | 4-particle 1D LJ chain, spacing 1.12, cutoff 2.5 |
| Integrator | Velocity-Verlet, dt=0.004, 8 steps |
| Li checksum | Normalized energy drift \|E₁−E₀\| / max(\|E\|) |
| LAMMPS | **External binary stub** — `csv_lang=lammps` (not bundled) |
| GROMACS | **External binary stub** — `csv_lang=gromacs` (not bundled) |

## License notes

- **LAMMPS** — GPL-2.0; not redistributed in CI.
- **GROMACS** — LGPL-2.1+; not redistributed in CI.
- Enable local drivers with `LI_MD_ORACLE_LAMMPS=1` / `LI_MD_ORACLE_GROMACS=1` when binaries are on PATH (B1+).

## Registry

| Path | Role |
|------|------|
| `benchmarks/competitive/md_oracle.toml` | Competitive row + competitor metadata |
| `benchmarks/competitive/md_oracle_competitive_common.py` | Python mirror of Li MD oracle |
| `benchmarks/competitive/registry.toml` | `lammps_lj_micro` / `gromacs_lj_micro` watch rows |

## WP-SCI-03 tie-in

`run_algo_registry` dispatches algo id **104** (`md_oracle_external`) through the tier-2 MD oracle checksum; see `run_algo_registry_tier2.li`.
