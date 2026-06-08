# Kokkos memory + execution spaces rubric (Li tier-2)

**Issue:** [lic#110](https://github.com/li-langverse/lic/issues/110)  
**Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**north_star_fit:** HPC / tier-2 physics · **PH-7e**, **PH-7d**, **G-par**, **G-gpu**

Li defines a **minimal, provable** memory-space and execution-space model aligned with Kokkos 4.5–4.6 production semantics so tier-2 physics can migrate from `shared_c_kernel` rows to pure-Li kernels **without silent host↔device copies**.

## Competitive rubric (Kokkos 4.6 → Li)

| Kokkos 4.6 concept | Li requirement | Proof / gate |
|--------------------|----------------|--------------|
| `Kokkos::MemorySpace` (`HostSpace`, `CudaSpace`, `HIPSpace`, `SYCLSpace`, `HBWSpace`) | `MemorySpace` enum: `Host`, `Device`, `Unified` (HBW alias documented) | Compile-time placement tag on buffer type; no runtime space discovery |
| `Kokkos::ExecutionSpace` (`Serial`, `OpenMP`, `Threads`, `Cuda`, `HIP`, `SYCL`) | `ExecutionSpace` enum: `Serial`, `OpenMP`, `Threads` (v1); `SYCL`/`Cuda`/`HIP` reserved for [#116](https://github.com/li-langverse/lic/issues/116) | Decorator stack selects space; **Threads vs OpenMP** conflict documented |
| `Kokkos::View` allocation + deallocation | `View[T, Space, Layout]` lifecycle: construct → use → destroy in **same** space unless explicit sync | Compile error on cross-space read without prior `@sync_*` |
| `deep_copy(src, dst)` | Named sync intrinsics: `@sync_host(view)`, `@sync_device(view)` (names TBD; spec-only in v1) | **G-par** + **G-gpu**: sync points appear in MIR telemetry |
| `DualView` deprecation (4.6) | **No implicit dual view** — host mirror is explicit `hostbuffer[T]` paired with `devicebuffer[T]` | Reject API that auto-syncs on read |
| Graph API / composite loops (4.6 [#7513](https://github.com/kokkos/kokkos/issues/7513)) | Defer graph capture to [#15](https://github.com/li-langverse/lic/issues/15) / [#116](https://github.com/li-langverse/lic/issues/116) | Plan-only note; no graph codegen in v1 |
| H100-oriented reductions | Map to `@parallel(reduction=…)` + execution-space tag; perf after proof | Tier-2 bench unchanged until pure-Li lands |
| OpenMP vs Threads pool conflict | **Policy:** default `OpenMP` execution space; `Threads` opt-in with runtime warning if libomp also linked | See [Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391), [LAMMPS Kokkos+OpenMP guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) |

## Li surface (v1 — spec + std constants)

```li
import std.execution.memory_spaces

# MemorySpace: 0=Host, 1=Device, 2=Unified
# ExecutionSpace: 0=Serial, 1=OpenMP (tier-2 default), 2=Threads
```

Full `View[T, Space, Layout]` typing and `@sync_*` intrinsics are **spec-only** until [#128](https://github.com/li-langverse/lic/issues/128) layout ABI and [#15](https://github.com/li-langverse/lic/issues/15) decorator lowering land.

## Copy / sync contract (decorator stack → required sync)

| Decorator stack | Data placement | Required sync before device read |
|-----------------|----------------|----------------------------------|
| `@cpu` only | `Host` | None |
| `@cpu` `@parallel` | `Host` (OpenMP team) | None |
| `@gpu` + `hostbuffer[T]` | Host mirror | `@sync_device` before `@gpu` kernel body |
| `@gpu` + `devicebuffer[T]` | Device | `@sync_host` before host-side checksum / I/O |
| `@cpu` `@gpu` (hetero) | Split buffers | Both directions explicit; no DualView |

Cross-space read without a documented sync point is a **compile error** (post-approval `li-tests/hpc/memory_spaces/`).

## External signals

- [Kokkos 4.6.02 release](https://github.com/kokkos/kokkos/releases/tag/4.6.02) — SYCL production, graph API, DualView deprecation trajectory
- [Kokkos 4.6 composite loops / reductions (#7513)](https://github.com/kokkos/kokkos/issues/7513)
- [Explorer digest](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/explorer-digests/2026-05-20-explorer.md) — Kokkos `missing` in `hpc_libraries`

## Related issues

| Track | Issue | Role |
|-------|-------|------|
| Layout ABI | [#128](https://github.com/li-langverse/lic/issues/128) | `ndview` extents, SoA/AoS |
| Decorator lowering | [#15](https://github.com/li-langverse/lic/issues/15) | `@cpu` / `@gpu` → sync MIR tags |
| Offload codegen | [#116](https://github.com/li-langverse/lic/issues/116) | OpenMPTarget / SYCL |
| Vendor policy | [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27) | Kokkos 4.6.x pin |
