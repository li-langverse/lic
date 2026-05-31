# PETSc–Kokkos exascale patterns → Li execution + memory model (requirements)

**Date:** 2026-05-31  
**Status:** Normative requirements (planning slice for lic#28)  
**Issue:** [lic#28](https://github.com/li-langverse/lic/issues/28)  
**Related:** [lic#15](https://github.com/li-langverse/lic/issues/15) (Kokkos-class lowering), [execution surface](2026-05-25-li-execution-surface.md), [execution resources](2026-05-25-li-execution-resources.md), [execution decorators](2026-05-16-li-execution-decorators.md)  
**PH / G:** PH-7e, PH-7d, **G-par**, **G-gpu** (partial), **G-async** (future)  
**Intel:** [ALCF PETSc exascale](https://www.alcf.anl.gov/news/optimizing-petsc-exascale), [arXiv:2406.08646](https://arxiv.org/html/2406.08646v1), [PETSc-users Kokkos thread](https://lists.mcs.anl.gov/pipermail/petsc-users/2024-June/050848.html)

## Problem

Exascale solver stacks (PETSc 3.25+, hypre, Trilinos) treat **Kokkos** as the performance-portability substrate: one `parallel_for` / `View` API over Serial, OpenMP, CUDA, HIP, and SYCL backends. Vendor-specific duplication is pushed behind execution spaces and memory spaces.

Li today has **CPU-first** execution decorators and proved `parallel for`, but no normative mapping from Kokkos-class **execution space + memory space + data movement + async fence** semantics to Li surface syntax and proof obligations.

This spec captures **Li-facing requirements** so compiler, stdlib, and solver integrations can land incrementally without breaking provability-first ordering.

!!! note "Provability status"
    Li does **not** claim Kokkos/PETSc parity today. Requirements below are **targets** with explicit done gates. See [Provability gaps](../../verification/provability-gaps.md) (**G-par**, **G-gpu**, **G-dec**).

## Design principles (Li adaptation)

| Kokkos / PETSc practice | Li requirement |
| ----------------------- | -------------- |
| Single source loop over backends | `@cpu` / `@parallel` / `@gpu` decorators + `parallel for`; backend chosen at **build** time via `lig` / `[execution]`, not duplicated user kernels |
| Execution space selects where work runs | **Execution placement axis** — separate from SIMD lanes and compile `--jobs` ([execution resources](2026-05-25-li-execution-resources.md)) |
| Memory space tags where data lives | **Memory placement axis** — host vs device vs unified; must be **type-visible** before codegen (**G-gpu**) |
| `View` ownership + layout | `array` / future strided buffer ABI; no silent alias across spaces |
| `deep_copy` / mirror views | **Explicit** host↔device transfers; compiler rejects implicit cross-space reads |
| `fence()` / stream ordering | **Async completion** contract on `@async` regions (**G-async**); no data race on completion |
| PETSc `VecGetKokkosView` | Solver FFI uses Li buffer contracts; device views require proved disjoint + space match |

## Requirement map

### R1 — Execution spaces (portable placement)

| Kokkos execution space | Li v1 surface | Proof gate |
| -------------------- | ------------- | ---------- |
| `Serial` | default / `@serial` on inner `for` | none beyond usual VC |
| `OpenMP` / `Threads` | `parallel for` + `@parallel(disjoint=…)` + `--cores` | **G-par** disjoint required |
| `Cuda` / `HIP` / `SYCL` | `@gpu` / `@gpu(devices=N)` on `def` (MIR telemetry today) | **G-gpu** address-space proofs before emit |
| `OpenMPTarget` | deferred; track in competitive registry | plan-only until PH-7e tier-2 |

**Done gate (R1 partial, shipped):** `@gpu` MIR tags + `@parallel` disjoint policy tests in `li-tests/decorators/` and `li-tests/race_shared_memory/`.

**Done gate (R1 full):** LKIR lowering for `@gpu` kernels with backend selected by `lig`; no duplicate `.li` sources per vendor.

### R2 — Memory spaces (data placement)

| Kokkos memory space | Li requirement | Status |
| ------------------- | -------------- | ------ |
| `HostSpace` | default stack/heap arrays | shipped |
| `CudaSpace` / `HIPSpace` | `gpu_array[T, N]` or buffer handle with `Space=Device` attribute | **G-gpu** open |
| `CudaUVMSpace` / unified | explicit `unified` opt-in; document coherence rules | future |
| `SharedSpace` | host-side staging for MPI+GPU; requires `Sync` + fence | future |

**Data movement rules (normative):**

1. **No implicit copy** — reading host data from a `@gpu` region without an explicit `copy_to_device` / `mirror_sync` API is a **compile error**.
2. **Space match on capture** — values captured into `parallel for` or `@gpu def` must satisfy `Send`/`Sync` **and** memory-space compatibility (future Lean laws).
3. **Write-back ordering** — after device write, host read requires `fence()` or scoped `with_fence { … }` (**G-async**).
4. **PETSc-style views** — foreign `Vec`/`Mat` handles expose `view(space=…)` accessors; Li side proves layout + alignment before bind.

### R3 — Portable loops (Kokkos `parallel_for` class)

Kokkos `parallel_for(policy, lambda)` maps to Li:

```nim
@parallel(disjoint=disjoint_elem)
parallel for i in 0..<N
  requires disjoint_elem(i, buf)
  decreases N - i
=
  @vectorized(lanes=8)
  for k in 0..<row_len(i)
    accumulate(i, k, buf)
```

| Kokkos feature | Li equivalent | Proof |
| -------------- | --------------- | ----- |
| `RangePolicy` | `parallel for i in 0..<N` | disjoint clause |
| `TeamPolicy` | future `team(cores=4) { … }` ([execution surface](2026-05-25-li-execution-surface.md)) | nested disjoint |
| `MDRangePolicy` | nested `parallel for` + `@vectorized` inner | product disjoint |
| `parallel_reduce` | `parallel for` + proved associative reducer temp | **G-par** + **G-math** |

**PH-7d attachment:** decorator stacks elaborate top-to-bottom; inner `@vectorized` never spawns OS threads. Policy proofs attach at the **outermost** parallel region.

### R4 — Async kernel launch story

| Kokkos / PETSc pattern | Li requirement |
| ------------------------ | -------------- |
| CUDA stream / Kokkos exec instance | `@async` on `def` + runtime queue per device (**G-async**) |
| Non-blocking launch + `fence()` | `launch_async { … }` returns handle; `await(h)` or scope exit fence |
| PETSc GPU KSP with host staging | solver step splits: host assemble → `copy_to_device` → `@gpu` apply → `fence` → host converge check |
| Overlapping comm/compute | explicit `prefetch` + `disjoint` on ghost cells; no unproved shared slot writes |

**Done gate (R4):** document + compile_fail fixtures for missing fence before host read; JobGraph async in [ml-async-parallel RFC](../../game-dev/specs/ml-async-parallel-rfc.md) is the **CPU** slice only.

### R5 — Solver-stack / exascale ecosystem framing

PETSc+Kokkos integration at exascale implies:

1. **One performance-portability spine** — Li defers vendor codegen to `lig`; user writes proved loops once ([lic#15](https://github.com/li-langverse/lic/issues/15)).
2. **Device-native preconditioners** (e.g. PCBJKOKKOS) — tier-2 implicit PDE benchmarks must label `shared_c_kernel` vs `pure_li`; tracked separately in [competitive landscape](../../benchmarks/competitive-landscape.md).
3. **MPI × threads × GPU occupancy** — see lic#129; this spec does not duplicate affinity rubric.
4. **Quarterly release cadence watch** — Kokkos/PETSc versions recorded in `scripts/hpc-competitive-snapshot.sh` env pins.

## Cross-links

| Artifact | Role |
| -------- | ---- |
| [lic#15](https://github.com/li-langverse/lic/issues/15) | Compiler lowering: decorators → LKIR/OpenMP/GPU |
| [lic#117](https://github.com/li-langverse/lic/issues/117) | PETSc device-native preconditioner rubric |
| [lic#110](https://github.com/li-langverse/lic/issues/110) | Kokkos View / execution-space semantics |
| `data/swarm-gap-registry/registry.yaml` `gap-hpc-kokkos-execution-memory-spaces` | Gap tracking |
| [simd-parallel handbook](../../language/simd-parallel.md) | User-facing CPU parallelism today |

## Acceptance checklist (lic#28)

- [x] Li-facing requirements for execution spaces, memory spaces, data movement, async fences
- [x] PH-7d / G-par proof attachment rules for portable loops
- [x] Cross-link lic#15 and existing execution specs
- [ ] MIR/LKIR lowering for `@gpu` kernels (lic#15 — separate issue)
- [ ] Lean memory-space laws (**G-gpu**)
- [ ] PETSc FFI view bindings (tier-2 PDE track)

## Agent notes

North star fit: **scientific computing / HPC** — PH-7e (native HPC), PH-7d (decorators), G-par (parallel safety), G-gpu (device placement). Proof before perf: requirements forbid implicit cross-space access and unproved shared mutation.
