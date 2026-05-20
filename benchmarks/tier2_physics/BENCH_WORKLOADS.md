# Tier-2 workload classes (honesty)

Benchmarks in this tree are **not** all comparable “game engine” simulations. Use `workload_class` in org `catalog.toml` when ingesting dashboards.

| Class | Meaning | Examples |
|-------|---------|----------|
| **full** | Problem size and numerics match a serious reference workload | `wave_equation_1d/2d`, `heat_equation_2d`, `advection_diffusion_2d`, `nbody_gravity`, `harmonic_oscillator_chain`, `double_pendulum`, `three_body`, `md_lennard_jones` (C kernel) |
| **v0_gaming** | Recognizable game/sim loop, **scaled up** from micro-stubs but still missing production physics | `euler_fluid_2d`, `wind_field_bc`, `combustion_passive`, `cloth_swing`, `ragdoll_chain`, `rigid_body_stack`, `sph_dam_break_2d`, `orbit_two_body`, `fdtd_waveguide_2d`, `schrodinger_1d_barrier` |
| **gaming_full** | Same algorithms as v0 at **full** `LI_BENCH_QUICK=0` scale (cloth PBD iterations, rigid stack bodies) | `cloth_swing`, `rigid_body_stack` — use `bench.py --full` |
| **world_engine** | Timed world/replication/physics-frame paths (not Unreal parity) | `game_world_soa_10k`, `game_replication_encode`, `sim_physics_frame` in `tier2_world/` |
| **pure_li_stub** | Li path does not run the full C reference kernel | `md_lennard_jones` `main.li` micro-buffer |

## v0_gaming — what is implemented (2026-05)

| Bench | Scale (approx.) | Algorithm |
|-------|-----------------|-----------|
| `euler_fluid_2d` | 64×64, 8k steps | 2D scalar upwind advection (**not** Euler ρ,u,v,p) |
| `wind_field_bc` | 64×64, 5k steps | 2D advection + left inflow BC |
| `combustion_passive` | 128 cells, 3k steps | Local fuel burn → temperature bump (no transport) |
| `sph_dam_break_2d` | 512 particles, 10k steps | Gravity + pairwise repulsion (**no** SPH density/pressure) |
| `cloth_swing` | 16-link chain, 8k steps | Distance constraints + gravity |
| `ragdoll_chain` | 12 joints, 3.6k steps | Gravity + length constraints |
| `rigid_body_stack` | 50 bodies, 2k steps | Independent gravity + floor (**no** stacking collisions) |
| `schrodinger_1d_barrier` | 128 cells, 8k steps | Explicit 1D TDSE + rectangular barrier potential |
| `fdtd_waveguide_2d` | 128 cells 1D TE, 8k steps | 1D FDTD (name says 2D; Yee 2D TBD) |

For **wind/smoke/fluid at production scale**, prefer **`advection_diffusion_2d`** (128×128, 15k steps) until v1 gaming kernels land in **li-sim-*** packages.

## Timing policy

`bench.py` uses **3–6** timed runs (default **5**) after **one** warmup; CSV exports **`value`** = median, **`value_stdev`** = sample stdev (seconds). Sub-10 ms benches remain statistically noisy — interpret ratios with stdev, not median alone.
