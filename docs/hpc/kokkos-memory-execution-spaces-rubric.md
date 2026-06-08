# Kokkos memory + execution spaces rubric (Li tier-2)

**Status:** Active (rev. 1 — 2026-06-08)  
**Issue:** [lic#110](https://github.com/li-langverse/lic/issues/110) · **PH:** PH-7e, PH-7d · **Gaps:** G-par, G-gpu  
**Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)

Li’s pillar order applies: **provable explicit copy/sync** before device access; **easy** host/device/unified enums without Kokkos headers; **fast** only after proof — no silent DualView.

## Kokkos 4.6 → Li policy matrix

| Kokkos 4.6 concept | Li requirement | Proof / gate |
|--------------------|----------------|--------------|
| `Kokkos::MemorySpace` (`HostSpace`, `CudaSpace`, `HIPSpace`, `SYCLSpace`, `HBWSpace`) | `MemorySpace` enum: `Host`, `Device`, `Unified` (`HBWSpace` → `Unified` alias) | Static placement tag on buffer type; `std.execution.memory` tags today |
| `Kokkos::ExecutionSpace` (`Serial`, `OpenMP`, `Threads`, `Cuda`, `HIP`, `SYCL`) | `ExecutionSpace` enum: `Serial`, `OpenMP`, `Threads` (v1); `SYCL`/`Cuda`/`HIP` reserved (#116) | Decorator stack selects space; default tier-2 = `OpenMP` |
| `Kokkos::View` lifecycle | `View[T, Space, Layout]` — construct → use → destroy in **same** space unless explicit sync | Compile error on cross-space read without prior `@sync_*` (post-#15) |
| `deep_copy(src, dst)` | Named sync: `@sync_host(view)`, `@sync_device(view)` (names TBD; spec in [execution decorators](../superpowers/specs/2026-05-16-li-execution-decorators.md)) | Sync points in MIR telemetry |
| `DualView` deprecation (4.6) | **No implicit dual view** — explicit `hostbuffer[T]` + `devicebuffer[T]` pair | Reject API that auto-syncs on read |
| Graph API / composite loops (#7513) | Defer graph capture to #15 / #116 | Serial staging path for tier-2 pilot |
| H100-oriented reductions | `@parallel(reduction=…)` + execution-space tag | Perf after proof |
| OpenMP vs Threads pool conflict | **Policy:** default `OpenMP`; `Threads` opt-in with runtime warning if libomp also linked | [Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391) |

## Stdlib surface (v1)

```li
import std.execution.memory

# MemorySpace tags
memory_space_host()      # 0
memory_space_device()    # 1
memory_space_unified()   # 2

# ExecutionSpace tags (v1 selectable: Serial, OpenMP, Threads)
execution_space_default_tier2()  # OpenMP
```

Full `View[T, Space]` parser types: [language design §Tier-2 memory spaces](../superpowers/specs/2026-05-14-li-language-design.md#tier-2-memory-spaces-kokkos-class-ph-7e).

## Decorator → sync contract (preview)

| Decorator stack | Memory implication | Required sync before device kernel |
|-----------------|-------------------|-----------------------------------|
| `@cpu` only | Host-resident buffers | None |
| `@cpu` `@parallel` | Host shared address space | None (G-par disjoint) |
| `@gpu` + `devicebuffer` | Device-resident | `@sync_device` after host fill |
| `@gpu` kernel read | Device | `@sync_device` if host wrote since last sync |
| Host read after `@gpu` | Cross-space | `@sync_host` before host access |

Lowering owned by [#15](https://github.com/li-langverse/lic/issues/15); layout ABI by [#128](https://github.com/li-langverse/lic/issues/128).

## External signals

1. [Kokkos 4.6.02](https://github.com/kokkos/kokkos/releases/tag/4.6.02) — SYCL production, graph API, DualView deprecation trajectory.
2. [Kokkos 4.6 composite loops (#7513)](https://github.com/kokkos/kokkos/issues/7513) — H100 reductions; graph deferred.
3. [LAMMPS Kokkos+OpenMP guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html) — explicit execution-space choice for tier-2 staging.

## Related

- [Tier-2 shared_c_kernel migration rubric](tier2-shared-c-kernel-migration-rubric.md)
- [Competitive landscape](../benchmarks/competitive-landscape.md) — Kokkos watch row
- [Provability gaps](../verification/provability-gaps.md) — G-gpu cross-space obligation
