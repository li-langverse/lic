# Kokkos memory + execution spaces rubric (Li tier-2)

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110)  
**Spec:** [2026-06-08-li-tier2-memory-execution-spaces.md](../superpowers/specs/2026-06-08-li-tier2-memory-execution-spaces.md)  
**Updated:** 2026-06-08  
**north_star_fit:** Proof before perf — explicit copy/sync, no silent DualView

## Purpose

Map Kokkos 4.5–4.6 production semantics onto Li's tier-2 memory model so competitive review and bench harness authors can label rows honestly (`pure_li` vs `shared_c_kernel`) without guessing about host↔device copies.

## External signals

| Source | Relevance |
|--------|-----------|
| [Kokkos 4.6.02](https://github.com/kokkos/kokkos/releases/tag/4.6.02) | SYCL production, graph API, DualView deprecation |
| [Kokkos #7513](https://github.com/kokkos/kokkos/issues/7513) | Composite loops, H100 reductions — defer graph to #15 |
| [Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391) | OpenMP vs Threads pool conflict |
| [LAMMPS Kokkos+OpenMP guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) | Tier-2 staging patterns |

## Policy matrix

### Memory spaces

| Kokkos `MemorySpace` | Li `MemorySpace` | Buffer type | Copy rule |
|---------------------|------------------|-------------|-----------|
| `HostSpace` | `Host` | `hostbuffer[T]`, `array`/`grid` on host | No sync for host-only kernels |
| `CudaSpace` / `HIPSpace` / `SYCLSpace` | `Device` | `devicebuffer[T]` | `@sync_device` before kernel; `@sync_host` before host read |
| `HBWSpace` | `Unified` (documented) | Managed / HBW alias | Explicit policy per platform; not auto-sync |
| `DualView` (deprecated 4.6) | **Rejected** | Paired `hostbuffer` + `devicebuffer` | Explicit sync only; no implicit mirror |

### Execution spaces

| Kokkos `ExecutionSpace` | Li `ExecutionSpace` | v1 default | Hazard |
|------------------------|----------------------|------------|--------|
| `Serial` | `Serial` | Debug / oracle | — |
| `OpenMP` | `OpenMP` | **Yes** for tier-2 | Safe with `li_par_pool` |
| `Threads` | `Threads` | Opt-in only | **Conflict** if libomp also linked |
| `Cuda` / `HIP` / `SYCL` | Reserved | — | #116 offload |

**Li default:** `ExecutionSpace.OpenMP` for tier-2 physics unless a row documents `Serial` for checksum oracle comparison.

### View lifecycle

| Kokkos operation | Li equivalent | Proof gate |
|-----------------|---------------|------------|
| `Kokkos::View::allocate` | Construct `View[T, Space, Layout]` | Space tag in type |
| `parallel_for` on View | `parallel for` + `disjoint_*` on host grid | **G-par** |
| `deep_copy(src, dst)` | `@sync_device` / `@sync_host` | MIR telemetry (#15) |
| `Kokkos::resize` | Explicit realloc + sync | No silent resize across spaces |
| `create_mirror_view` | Explicit `hostbuffer` pair | No DualView auto-sync |

## Decorator stack → sync points

| Stack | Memory | Sync required |
|-------|--------|---------------|
| `@cpu` + `parallel for` on `array` | Host only | None |
| `@cpu` + `hostbuffer` | Host pinned | None |
| `@gpu` + `devicebuffer` | Device | `@sync_device` before launch if host wrote data |
| `@gpu` then host checksum | Device → host | `@sync_host` before `li_rt_volatile_sink_*` |
| `@cpu` `@parallel` `@vectorized` (tier-2 pilot) | Host | None — stage 1 of `heat_equation_2d` migration |

## OpenMP vs Threads policy

1. **Default:** `ExecutionSpace.OpenMP` — matches harness `-fopenmp` and `li_par_pool`.
2. **Opt-in:** `ExecutionSpace.Threads` only when Kokkos/Trilinos-style pthread pool is intentional.
3. **Runtime:** if both OpenMP and Threads backends are linked, emit documented warning (future `li_rt` gate).
4. **Bench honesty:** registry `notes` must name execution space when not OpenMP.

## Competitive registry (lic copy)

Kokkos row in `benchmarks/competitive/registry.toml` stays `track = "watch"` until a harness column exists. Vendor pin handoff: [benchmarks-kokkos-vendor-handoff.md](../ecosystem/benchmarks-kokkos-vendor-handoff.md) → benchmarks [#27](https://github.com/li-langverse/benchmarks/issues/27).

## Review checklist (agents)

Before changing tier-2 bench rows or HPC std:

- [ ] Read this rubric + [tier-2 migration appendix](tier2-shared-c-migration-heat-equation-2d.md)
- [ ] Label `kernel_honesty` correctly (`pure_li` vs `shared_c_kernel`)
- [ ] No threshold changes while on shared C
- [ ] Cross-space access names explicit sync in source or spec
- [ ] `./scripts/check-hpc-competitive.sh` passes
