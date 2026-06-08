# Kokkos 4.6 → Li memory & execution spaces rubric

**Status:** Spec (lic#110) · **north_star_fit:** HPC tier-2 physics · **PH-7e**, **PH-7d**, **G-par**, **G-gpu**  
**Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**Related:** [execution-space rubric](kokkos-execution-space-rubric.md) · [shared-C migration appendix](shared-c-kernel-migration-appendix.md) · [language design §Phase 3](../superpowers/specs/2026-05-14-li-language-design.md)

## Purpose

Map Kokkos 4.6 production semantics to Li's **minimal** memory-space and execution-space model so tier-2 physics kernels can migrate off `shared_c_kernel` rows without silent host↔device copies. This rubric is the policy matrix for [#110](https://github.com/li-langverse/lic/issues/110); layout/stride ABI is [#128](https://github.com/li-langverse/lic/issues/128).

## Kokkos 4.6.02 signals (2026)

| Signal | Li implication |
|--------|----------------|
| SYCL backend production-ready | Reserve `ExecutionSpace.SYCL` for #116; no SYCL headers in user Li |
| DualView deprecation trajectory | **No implicit dual view** — explicit `hostbuffer` + `devicebuffer` pair |
| Graph API / composite loops ([#7513](https://github.com/kokkos/kokkos/issues/7513)) | Defer graph capture to #15 / #116; serial staging for tier-2 pilot |
| H100-oriented reductions | Map to `@parallel(reduction=…)` + execution-space tag after proof |
| OpenMP vs Threads pool conflict ([#1391](https://github.com/trilinos/Trilinos/issues/1391)) | Default `OpenMP`; `Threads` opt-in — see [execution-space rubric](kokkos-execution-space-rubric.md) |

## Policy matrix

| Kokkos 4.6 concept | Li surface | Proof / gate |
|--------------------|------------|--------------|
| `Kokkos::HostSpace` | `MemorySpace.Host` | Static tag on `hostbuffer[T]` / `View[T, Host, Layout]` |
| `Kokkos::CudaSpace` / `HIPSpace` / `SYCLSpace` | `MemorySpace.Device` | Static tag on `devicebuffer[T]`; backend chosen by `lig` config (#116) |
| `Kokkos::HBWSpace` | `MemorySpace.Unified` (HBW alias documented) | NUMA/HBW affinity maps via #129 |
| `Kokkos::Serial` | `ExecutionSpace.Serial` | `@cpu` + no `parallel for` |
| `Kokkos::OpenMP` | `ExecutionSpace.OpenMP` | **Default** for tier-2 `@parallel` |
| `Kokkos::Threads` | `ExecutionSpace.Threads` | Opt-in; hazard if libomp also linked |
| `Kokkos::View` | `View[T, Space, Layout]` | Lifecycle in **same** space unless explicit sync |
| `deep_copy(src, dst)` | `@sync_host(v)` / `@sync_device(v)` | MIR telemetry; compile error without sync before cross-space read |
| `DualView` | **Rejected** — explicit pair only | No auto-sync on read |

## Copy / sync contract (decorator stack → MIR)

Feeds [#15](https://github.com/li-langverse/lic/issues/15) decorator lowering.

| User surface | Elaboration | Sync obligation |
|--------------|-------------|-----------------|
| `@cpu def f()` using `hostbuffer[T]` | `ExecutionSpace.Serial` or `OpenMP` (per `--cores`) | None if all buffers `Host` |
| `@parallel def f()` on `hostbuffer[T]` | `ExecutionSpace.OpenMP` default | Disjoint proof (**G-par**) on shared host memory |
| `@gpu def f()` on `devicebuffer[T]` | `ExecutionSpace.Device` + placement tag | `@sync_device` before kernel if host wrote since last sync |
| `@gpu def f()` reading `hostbuffer[T]` | **Compile error** unless `@sync_device` preceded host write | **REQ-SYNC-02** |
| `hostbuffer` + `devicebuffer` pair | Explicit dual — not `DualView` | `@sync_host` / `@sync_device` at phase boundaries |
| `View[T, Host, Layout]` passed to `@gpu` kernel | **Compile error** | Must `@sync_device` copy to `View[T, Device, Layout]` first |

Layout parameter `Layout` defers to [#128](https://github.com/li-langverse/lic/issues/128) (`RowMajor`, `ColMajor`, `SoA`, `AoS`).

## REQ mapping

| ID | Requirement | This doc |
|----|-------------|----------|
| **REQ-MS-01** | `MemorySpace` enum: `Host`, `Device`, `Unified` | Policy matrix |
| **REQ-MS-02** | Buffer types carry static space tag | `View[T, Space, Layout]` row |
| **REQ-ES-01** | `ExecutionSpace` enum; OpenMP default | Policy matrix + execution-space rubric |
| **REQ-ES-02** | Threads vs OpenMP conflict documented | [kokkos-execution-space-rubric.md](kokkos-execution-space-rubric.md) |
| **REQ-SYNC-01** | Explicit `@sync_host` / `@sync_device` | Copy/sync contract table |
| **REQ-SYNC-02** | Compile error on cross-space read without sync | Copy/sync contract table |

## Honesty fence

- **In scope (this PR):** policy matrix, spec enums, migration appendix, vendor handoff checklist, provability-gaps update.
- **Out of scope:** parser/codegen, LKIR lowering, tier-2 threshold changes, `trusted.lean` edits.
- **Deferred:** `li-tests/hpc/memory_spaces/` compile-fail corpus until #15 MIR tags land.

## References

- [Kokkos 4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02)
- [Kokkos 4.6 composite loops (#7513)](https://github.com/kokkos/kokkos/issues/7513)
- [Trilinos OpenMP vs Threads (#1391)](https://github.com/trilinos/Trilinos/issues/1391)
- [LAMMPS Kokkos+OpenMP guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html)
- [Execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)
- [Provability gaps — G-par / G-gpu](../verification/provability-gaps.md)
