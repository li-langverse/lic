# shared_c_kernel → explicit copy semantics — tier-2 migration appendix

**Status:** Spec (lic#110) · **Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Parent:** [kokkos-memory-execution-spaces-rubric.md](kokkos-memory-execution-spaces-rubric.md)

## Problem

Today many tier-2 rows use `kernel_honesty = shared_c_kernel`: Li drivers link the same C oracle (`LI_EXTRA_C`) as Rust/Julia wrappers. Device placement and host↔device copies are **implicit** in the C runtime — invisible to `lic build` proof obligations.

Li's Kokkos-aligned model requires **named** memory spaces and **explicit** sync before cross-space access (**REQ-SYNC-01/02**).

## Migration rubric

| Stage | Row state | `kernel_honesty` | Copy semantics |
|-------|-----------|------------------|----------------|
| **S0** (today) | Li driver + shared C oracle | `shared_c_kernel` | Implicit in C; not proved |
| **S1** | Pure-Li host kernel `@cpu` `@parallel` | `pure_li` | All buffers `MemorySpace.Host`; no device |
| **S2** | Host compute + explicit device staging | `pure_li` | `hostbuffer` + `devicebuffer` pair; `@sync_device` at phase boundary |
| **S3** | Drop `LI_EXTRA_C` | `pure_li` | Full Li proof surface; checksum gate unchanged |

**Gate:** Do not advance stage if `bench.py --verify` checksum drifts or `threshold_ratio_cpp` weakens.

## Row inventory (priority)

| Bench ID | Current | Target stage (v1) | Blocker |
|----------|---------|-------------------|---------|
| `heat_equation_2d` | S0 — shared C heat stencil | **S1 → S2** (pilot) | #128 layout names for 2D grid |
| `md_lennard_jones` | S0 — `md_core.c` | **S1** (host-only first) | #128 SoA layout for neighbor list |
| `three_body` | S0 | S1 | Host-only feasible now |
| `nbody_gravity` | S0 | S1 | Host-only feasible now |

## Pilot: `heat_equation_2d` staged path

Reference harness: `benchmarks/tier2_physics/heat_equation_2d/` (synced from benchmarks repo).  
Oracle today: `sim_scientific_oracle_checksum_heat()` in `li-sim-scientific` (explicit 1D laplacian stencil on host).

### Phase 1 — host-only pure-Li (S1)

```text
1. Replace LI_EXTRA_C driver with pure-Li stencil using hostbuffer[f64] or array[N, f64]
2. Tag def with @cpu and @parallel(disjoint=disjoint_row) on interior rows
3. ExecutionSpace.OpenMP default; checksum via li_rt_volatile_sink_f64
4. bench.py --verify heat_equation_2d: checksum unchanged
5. Label kernel_honesty=pure_li in competitive registry notes
```

**Exit:** green verify row; `li_pure=True` in harness metadata.

### Phase 2 — explicit device staging (S2)

```text
1. Allocate hostbuffer[f64] (initial field) + devicebuffer[f64] (kernel workspace)
2. After host initialization: @sync_device(host_view)
3. @gpu def heat_step_device(...) on devicebuffer only
4. Before host checksum: @sync_host(device_view)
5. MIR dump shows sync tags (requires #15 lowering)
```

**Exit:** MIR telemetry lists `@sync_device` / `@sync_host`; no silent copy in compiler log.  
**Blocked on:** #128 `View[T, Space, Layout]` layout ABI + #15 sync MIR tags.

### Phase 3 — drop shared C (S3)

```text
1. Remove LI_EXTRA_C from harness params.toml
2. Confirm competitive registry row notes pure_li
3. File benchmarks ingest PR if dashboard path labels change
```

## `md_lennard_jones` (secondary)

Follow S1 only in v1: pure-Li velocity-Verlet on host with `MemorySpace.Host`. Device path deferred until neighbor-list SoA layout (#128) and MD checksum oracle export real `ensures` (**G-physics** modeling_gap).

## Verification commands

```bash
# After S1 lands (benchmarks tree present):
python3 benchmarks/harness/bench.py --tier 2 --only heat_equation_2d --verify-results

# Competitive registry honesty:
./scripts/check-hpc-competitive.sh
```

## Cross-links

- [#41 benchmarks pure-Li expansion](https://github.com/li-langverse/benchmarks/issues/41)
- [#128 mdspan ABI](https://github.com/li-langverse/lic/issues/128)
- [#15 decorator lowering](https://github.com/li-langverse/lic/issues/15)
- `packages/li-sim-scientific` — `run_heat_tier2_registry`, `sim_scientific_oracle_checksum_heat`
