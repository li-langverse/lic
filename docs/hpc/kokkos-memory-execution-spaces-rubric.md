# Kokkos memory + execution spaces rubric (Li tier-2)

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · **Plan:** [2026-06-07-kokkos-memory-execution-spaces-110](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**north_star_fit:** HPC tier-2 physics · **PH-7e**, **PH-7d**, **G-par**, **G-gpu**

Li defines **where data lives** (`MemorySpace`) and **who may run kernels** (`ExecutionSpace`) before tier-2 rows migrate off `shared_c_kernel`. No Kokkos headers; no silent DualView.

## Kokkos 4.6 → Li policy matrix

| Kokkos 4.6 concept | Li requirement | Proof / gate |
|--------------------|----------------|--------------|
| `Kokkos::MemorySpace` (`HostSpace`, `CudaSpace`, `HIPSpace`, `SYCLSpace`, `HBWSpace`) | `MemorySpace` enum: `Host`, `Device`, `Unified` (`HBWSpace` documented alias of `Unified` on tiered DRAM) | Static placement tag on buffer type; no runtime space discovery |
| `Kokkos::ExecutionSpace` (`Serial`, `OpenMP`, `Threads`, `Cuda`, `HIP`, `SYCL`) | `ExecutionSpace` enum: `Serial`, `OpenMP`, `Threads` (v1); `SYCL`/`Cuda`/`HIP` reserved for [#116](https://github.com/li-langverse/lic/issues/116) | Decorator stack selects space; default tier-2 = `OpenMP` |
| `Kokkos::View` alloc / dealloc | `View[T, Space, Layout]` lifecycle: construct → use → destroy in **same** space unless explicit sync | Compile error on cross-space read without prior sync |
| `deep_copy(src, dst)` | `@sync_host(view)`, `@sync_device(view)` — see [copy-sync contract](copy-sync-contract-110.md) | Sync points in MIR telemetry (**G-par**, **G-gpu**) |
| `DualView` deprecation (4.6) | **No implicit dual view** — explicit `hostbuffer[T]` + `devicebuffer[T]` pair | Reject API that auto-syncs on read |
| Graph API / composite loops ([#7513](https://github.com/kokkos/kokkos/issues/7513)) | Defer to [#15](https://github.com/li-langverse/lic/issues/15) / #116; serial staging for tier-2 pilot | Plan note only in v1 |
| H100-oriented reductions | `@parallel(reduction=…)` + execution-space tag; perf after proof | Bench checksum unchanged until pure-Li lands |
| OpenMP vs Threads pool conflict ([Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391)) | **Policy:** default `OpenMP`; `Threads` opt-in with runtime warning if libomp also linked | Documented below |

## Execution-space default (tier-2)

| Context | Default `ExecutionSpace` | Override |
|---------|------------------------|----------|
| Tier-2 physics harness (`LI_PARALLEL=1`) | `OpenMP` | `ExecutionSpace.Threads` opt-in (documented hazard) |
| Host-only pure-Li oracle (`heat_equation_2d` stage 1) | `Serial` or proved `@parallel` on host | `@cpu` decorator |
| Device pilot (post-#116) | `SYCL` / `Cuda` via `@gpu` | lig vendor config — not source strings |

**Threads vs OpenMP:** Li does not nest Kokkos `Threads` inside an active OpenMP team. If both runtimes are linked, emit `LI_RT_EXEC_SPACE_WARN=1` advisory at process start when `ExecutionSpace.Threads` is selected.

## View surface (spec)

```li
# Spec — not yet in parser (see language design §Phase 3 HPC)
type View[T, Space: MemorySpace, Layout: LayoutTag] = ...
```

| Parameter | v1 | Owner issue |
|-----------|-----|-------------|
| `T` | Element type (`float`, `f64`, …) | #110 |
| `Space` | `MemorySpace` | #110 |
| `Layout` | `LayoutLeft` / `LayoutRight` / stride ABI | [#128](https://github.com/li-langverse/lic/issues/128) |

Paired buffers (no DualView):

| Type | `MemorySpace` | Role |
|------|---------------|------|
| `hostbuffer[T]` | `Host` | Pinned/pageable host mirror |
| `devicebuffer[T]` | `Device` | Device-resident storage |
| `View[T, Unified, Layout]` | `Unified` | Managed memory — explicit sync still required for proof |

## External signals

1. [Kokkos 4.6.02](https://github.com/kokkos/kokkos/releases/tag/4.6.02) — SYCL production, graph API, DualView deprecation trajectory.
2. [Composite loops / reductions #7513](https://github.com/kokkos/kokkos/issues/7513).
3. [LAMMPS Kokkos+OpenMP guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) — explicit execution-space staging.

## Stdlib

Enums live in `std/hpc/memory.li` (`MemorySpace`, `ExecutionSpace` types; variant literals post-#15). Import: `import std.hpc.memory`.
