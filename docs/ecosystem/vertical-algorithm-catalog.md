# Vertical algorithm catalog (stub index)

**Status:** Stub index (2026-05-23) — expand one section per vertical as kernels land.  
**Registry:** [benchmarks/competitive/verticals.toml](../../benchmarks/competitive/verticals.toml)  
**UX intel:** [game-dev/competitive-intel/ui-ux-by-dimension.md](../game-dev/competitive-intel/ui-ux-by-dimension.md)

| Vertical | Kernel families (target) | Bench / verify | UX dimension |
|----------|-------------------------|----------------|--------------|
| Gaming rigid | semi-implicit integrate, collision | composable `physics.rigid` | UX-01 |
| MD | Lennard-Jones cutoff | tier-2 `md_lennard_jones` | UX-06 |
| PDE | explicit heat step | tier-2 `heat_equation_2d` | UX-06 |
| Drug LITL | stage workflow + QM queue | composable `sim.drug_design` | UX-07 |
| AM slicer | slice, preview, export | stub | UX-08, UX-09 |
| QM DFT | SCF energy | external oracle TBD | UX-07 |

Do not add marketing “on-par” claims without a `verticals.toml` row and green verify/bench evidence.
