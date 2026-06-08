# Kokkos memory + execution spaces — Li tier-2 rubric (#110)

**Status:** Normative policy (plan-approved 2026-06)  
**Issue:** [#110](https://github.com/li-langverse/lic/issues/110) · **Plan:** [2026-06-07-kokkos-memory-execution-spaces-110.md](../superpowers/plans/2026-06-07-kokkos-memory-execution-spaces-110.md)  
**north_star_fit:** HPC tier-2 physics · **PH-7e**, **PH-7d**, **G-par**, **G-gpu**

Li defines a **Kokkos-class** memory and execution model without Kokkos headers. The goal is explicit placement and sync — no silent `DualView`-style host↔device copies.

---

## Memory spaces (`MemorySpace`)

| Li enum | Kokkos 4.6 analog | Semantics |
|---------|-------------------|-----------|
| `Host` | `HostSpace` | Process address space; default for tier-2 v1 |
| `Device` | `CudaSpace` / `HIPSpace` / `SYCLSpace` | Offload-resident buffer (Phase 4+ codegen) |
| `Unified` | `CudaUVMSpace` / unified SYCL USM | Single allocation visible on host and device; **explicit sync still required** for writes |

**HBW / high-bandwidth host:** map to `Host` with documented `arena` pin policy (Kokkos `HBWSpace` alias — no separate enum in v1).

**Rules (REQ-MS-01, REQ-MS-02):**

- Buffer types carry a **static** space tag (`hostbuffer[T]`, `devicebuffer[T]`, future `View[T, Space, Layout]`).
- No runtime space discovery (`Kokkos::UnknownSpace` pattern rejected).
- Construct → mutate → destroy in the **same** space unless an explicit sync intrinsic ran first.

Constants: `std/execution/memory_spaces.li` (`memory_space_host()`, …).

---

## Execution spaces (`ExecutionSpace`)

| Li enum (v1) | Kokkos analog | Default? | Notes |
|--------------|---------------|----------|-------|
| `Serial` | `Serial` | No | Single-thread reference builds |
| `OpenMP` | `OpenMP` | **Yes** (tier-2) | Maps to `parallel for` + `lic build --cores=N` |
| `Threads` | `Threads` | Opt-in | **Hazard:** conflicts with linked libomp (Trilinos [#1391](https://github.com/trilinos/Trilinos/issues/1391)) |
| `SYCL` | `SYCL` | Reserved (#116) | Production in Kokkos 4.6.02 |
| `Cuda` | `Cuda` | Reserved (#116) | Device team policy |
| `HIP` | `HIP` | Reserved (#116) | AMD offload |

**Policy (REQ-ES-01, REQ-ES-02):**

- Tier-2 physics benches default to **`OpenMP`** execution space.
- `Threads` requires explicit opt-in (`[execution] space = "threads"`) and documents the OpenMP pool conflict.
- Decorator stack (`@cpu`, `@parallel`, `@gpu`) selects execution space at compile time — see [copy/sync contract](#copysync-contract-decorator--sync-matrix).

Constants: `std/execution/memory_spaces.li` (`execution_space_openmp()`, …).

---

## View lifecycle (Kokkos `View` analog)

| Stage | Li surface (spec) | Gate |
|-------|-------------------|------|
| Allocate | `var v: View[f64, Host, Layout]` or `hostbuffer[T]` / `devicebuffer[T]` pair | Space tag static |
| Use (read/write) | Access only in matching execution space | Compile error on mismatch |
| Sync | `@sync_host(v)` / `@sync_device(v)` (names frozen at parser landing) | MIR telemetry tag |
| Deallocate | RAII / owner drop in same space as last write | No cross-space destructor |

**DualView deprecation (Kokkos 4.6):** Li rejects implicit dual views. Host mirror is an explicit `hostbuffer[T]` paired with `devicebuffer[T]` — never auto-sync on read.

---

## Copy/sync contract (decorator → sync matrix)

Sub-phase **C** — feeds [#15](https://github.com/li-langverse/lic/issues/15) decorator lowering.

| Decorator stack | Execution space | Required sync before device read | MIR tag (planned) |
|-----------------|-----------------|----------------------------------|-------------------|
| `@cpu` only | Host / Serial | None | `mir_exec_host` |
| `@cpu` + `@parallel(disjoint=…)` | OpenMP (default) | None (shared host RAM) | `mir_exec_openmp` |
| `@gpu` | Device | `@sync_device` after host fill | `mir_exec_device` |
| `@gpu` + `@parallel` | Device team | `@sync_device` before kernel; `@sync_host` before host checksum | `mir_exec_device_par` |
| Host fill → device kernel | Device | **Mandatory** `@sync_device` between stages | `mir_sync_device` |
| Device result → host verify | Host | **Mandatory** `@sync_host` before read | `mir_sync_host` |

**Cross-space read without prior sync:** compile error (REQ-SYNC-02). Lean proof obligation tracked under **G-gpu** — see [provability-gaps.md](../verification/provability-gaps.md).

Layout / stride types (`ndview`, SoA/AoS) are owned by [#128](https://github.com/li-langverse/lic/issues/128); this rubric owns **where** data lives, not **how** it is laid out.

---

## OpenMP vs Threads hazard

Kokkos practitioners report thread-pool conflicts when mixing `Kokkos::OpenMP` with `Kokkos::Threads` in one process ([Trilinos #1391](https://github.com/trilinos/Trilinos/issues/1391), [LAMMPS tuning guide](https://www.hpc-carpentry.org/tuning_lammps/07-kokkos-openmp/index.html)).

| Li policy | Rationale |
|-----------|-----------|
| Default `OpenMP` for tier-2 | Matches `parallel for` lowering today |
| `Threads` opt-in only | Avoid silent double thread pools |
| Link-time warning if both libomp and Li thread pool active | Document in release notes when runtime ships |

---

## Deferred (not v1)

| Kokkos 4.6 feature | Li deferral |
|--------------------|-------------|
| Graph API / composite loops ([#7513](https://github.com/kokkos/kokkos/issues/7513)) | #15 / #116 — serial staging for tier-2 pilot |
| H100-oriented reduction fusion | `@parallel(reduction=…)` after proof; perf after checksum parity |
| SYCL production backend | #116 OpenMPTarget checklist |

---

## Related docs

- [Tier-2 shared-C migration rubric](tier2-shared-c-migration.md)
- [Benchmarks Kokkos vendor handoff](benchmarks-kokkos-vendor-handoff.md)
- [Language design §Phase 3 memory spaces](../superpowers/specs/2026-05-14-li-language-design.md#memory-and-execution-spaces-ph-7e-110)
- [Execution decorators spec](../superpowers/specs/2026-05-16-li-execution-decorators.md)
