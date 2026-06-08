# Kokkos 4.6 → Li memory & execution spaces rubric

**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · **PH-7e**, **G-par**, **G-gpu**  
**Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**Status:** Normative policy (spec-only v1 — no parser / codegen in this slice)

## Purpose

Map [Kokkos 4.6.02](https://github.com/kokkos/kokkos/releases/tag/4.6.02) production semantics to Li’s tier-2 memory model so physics kernels can migrate from **`shared_c_kernel`** catalog rows to pure-Li code **without silent host↔device copies**.

Layout / stride ABI (`ndview`, SoA/AoS) is owned by [#128](https://github.com/li-langverse/lic/issues/128). Decorator lowering is [#15](https://github.com/li-langverse/lic/issues/15). GPU offload codegen is [#116](https://github.com/li-langverse/lic/issues/116).

## Competitive rubric

| Kokkos 4.6 concept | Li requirement | Proof / gate |
|--------------------|----------------|--------------|
| `Kokkos::MemorySpace` (`HostSpace`, `CudaSpace`, `HIPSpace`, `SYCLSpace`, `HBWSpace`) | `MemorySpace` enum: `Host`, `Device`, `Unified` (HBW alias documented) | Compile-time placement tag on buffer type; no runtime space discovery |
| `Kokkos::ExecutionSpace` (`Serial`, `OpenMP`, `Threads`, `Cuda`, `HIP`, `SYCL`) | `ExecutionSpace` enum: `Serial`, `OpenMP`, `Threads` (v1); `SYCL`/`Cuda`/`HIP` reserved for #116 | Decorator stack selects space; **Threads vs OpenMP** conflict documented below |
| `Kokkos::View` allocation + deallocation | `View[T, Space, Layout]` lifecycle: construct → use → destroy in **same** space unless explicit sync | Compile error on cross-space read without prior sync |
| `deep_copy(src, dst)` | Named sync intrinsics: `@sync_host(view)`, `@sync_device(view)` | **G-par** + **G-gpu**: sync points appear in MIR telemetry |
| `DualView` deprecation (4.6) | **No implicit dual view** — host mirror is explicit `hostbuffer[T]` paired with `devicebuffer[T]` | Reject API that auto-syncs on read |
| Graph API / composite loops (4.6 [#7513](https://github.com/kokkos/kokkos/issues/7513)) | Defer graph capture to #15 / #116; document **serial** staging path for tier-2 pilot | Plan-only; no graph codegen in v1 |
| H100-oriented reductions | Map to `@parallel(reduction=…)` + execution-space tag; perf after proof | Tier-2 bench unchanged until pure-Li lands |
| OpenMP vs Threads pool conflict | **Policy:** default `OpenMP` execution space; `Threads` opt-in with runtime warning if libomp also linked | See [Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391) |

## Execution-space default policy

| Context | Default `ExecutionSpace` | Rationale |
|---------|--------------------------|-----------|
| Tier-2 physics harness (`heat_equation_2d`, `md_lennard_jones`) | `OpenMP` | Matches LAMMPS/Kokkos practitioner guidance; avoids nested thread-pool conflicts |
| Single-threaded oracle / CI smoke | `Serial` | Deterministic checksums; no pool init |
| Explicit opt-in | `Threads` | Allowed only when `LI_EXEC_SPACE=threads` and OpenMP runtime is **not** linked |

**Hazard (documented, not auto-detected in v1):** linking both Kokkos `Threads` and `OpenMP` backends (or Li equivalents) in one process can oversubscribe CPU cores. Li tier-2 rows must declare execution space in source or harness metadata — never rely on implicit runtime discovery.

## Memory-space placement (v1)

| `MemorySpace` | Kokkos analog | Li surface (Phase 3 spec) |
|---------------|---------------|---------------------------|
| `Host` | `HostSpace` | `hostbuffer[T]` — pageable or pinned host storage |
| `Device` | `CudaSpace` / `HIPSpace` / `SYCLSpace` | `devicebuffer[T]` — single backend selected by `lig` config |
| `Unified` | `CudaUVMSpace` / managed memory | `unifiedbuffer[T]` — explicit; no silent migration on read |

**HBWSpace:** document as `Host` with `LI_MEM_HBW=1` affinity hint (maps to [#129](https://github.com/li-langverse/lic/issues/129) NUMA policy). No separate enum value in v1.

## View lifecycle (normative)

```text
allocate(space) → write(space) → [optional @sync_device] → kernel(device) → [optional @sync_host] → read(host) → deallocate
```

Rules:

1. A `View[T, Space]` is **bound** to its allocation space for its lifetime.
2. Cross-space access requires an explicit sync intrinsic documented in [kokkos-copy-sync-contract.md](kokkos-copy-sync-contract.md).
3. Destroying a view in a different space than allocation is a **compile error** (post-approval codegen).
4. No `DualView`-style lazy mirror — paired buffers are two distinct types.

## External signals

1. [Kokkos 4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02) — SYCL production, graph API, DualView deprecation trajectory.
2. [Kokkos 4.6 composite loops / reductions (#7513)](https://github.com/kokkos/kokkos/issues/7513).
3. [Kokkos::OpenMP vs Threads (Trilinos #1391)](https://github.com/trilinos/Trilinos/issues/1391).
4. [LAMMPS Kokkos+OpenMP practitioner guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html).

## Related docs

- [Copy/sync contract](kokkos-copy-sync-contract.md)
- [Tier-2 shared-C migration](tier2-shared-c-kernel-migration.md)
- [Benchmarks Kokkos 4.6 vendor handoff](benchmarks-kokkos-4.6-vendor-handoff.md)
- [Language design §Phase 3](../superpowers/specs/2026-05-14-li-language-design.md#phase-3--shaped-arrays--gpu)
- [Execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)
