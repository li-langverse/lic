# Li `std/execution` offload rubric — Kokkos OpenMPTarget + OpenMP target

**Date:** 2026-06-07  
**Status:** Draft (plan **#116**)  
**Depends on:** [Execution decorators](2026-05-16-li-execution-decorators.md), [Execution surface](2026-05-25-li-execution-surface.md)  
**Blocked by:** [#34](https://github.com/li-langverse/lic/issues/34) OpenMP IR lowering (`plan-approved` required before codegen)  
**Companion:** [#110](https://github.com/li-langverse/lic/issues/110) memory-space ABI, [#129](https://github.com/li-langverse/lic/issues/129) host affinity

## Purpose

Provide a **checklist** mapping Li execution decorators and memory tags to:

1. Kokkos **OpenMPTarget** execution-space + memory-space practice  
2. OpenMP **`target` / `teams` / `distribute` / `parallel for` / `map`** clauses Li can lower once **#34** is approved  
3. **Explicit non-goals** where Li defers to vendor OpenMP target runtime behavior

This document is **normative for planning and review**. It does not enable codegen by itself.

## Principles

| Pillar | Rule |
|--------|------|
| Proof first | No `omp target` emit without **G-gpu** address-space obligations discharged |
| Honest benches | Tier-2 GPU columns forbidden until `tier2-offload-scope.md` in-scope gates pass |
| Vendor deferral | Compiler-specific `target` behavior documented as runtime non-goal, not hidden in Li semantics |
| Host/device separation | `@cpu` and `@gpu` stacks are mutually exclusive on the same `def` (compile error) |

## Decorator → Kokkos OpenMPTarget → OpenMP target

| Li decorator / config | Kokkos class analogue | OpenMP construct (post-#34) | Li can lower? | Proof |
|-----------------------|----------------------|----------------------------|---------------|-------|
| `@cpu` on `def` | `ExecutionSpace = OpenMP` / `Serial` | Host code only | **Yes** (host) | **G-par** |
| `@gpu` on `def` | `ExecutionSpace = OpenMPTarget` | `#pragma omp target` entry | **Planned** | **G-gpu** |
| `@parallel(disjoint=…)` on host `for` | `parallel_for` on HostSpace | `#pragma omp parallel for` | **Yes** (host) | **G-par** |
| `@parallel(disjoint=…)` under `@gpu` | `parallel_for` on OpenMPTarget | `target teams distribute parallel for` | **Planned** | **G-gpu**, **G-par** |
| `@vectorized(lanes=N)` | Vector width / SIMD | LLVM vectorize on host; **not** `declare simd` on target v1 | **Yes** (host) | **G-dec** |
| `@serial` | `Kokkos::Serial` | Single-threaded region | **Yes** | — |
| `@no_vectorize` | Disable vectorization | `llvm.loop.vectorize.disable` | **Yes** | **G-dec** |
| `[execution] parallel_backend = openmp_target` | `Kokkos::Initialization` selects OpenMPTarget | `-fopenmp` + target triple flags via `lig` | **Planned** | ops |
| `OMP_PROC_BIND` / `OMP_PLACES` | Kokkos OpenMP host backend | Host OpenMP env — see **#129** | **Doc + opt-in** | ops |

### `map` clause checklist (device data motion)

| Li buffer kind | Kokkos memory space | Default `map` policy | Proof required | Notes |
|----------------|--------------------|--------------------|----------------|-------|
| Host `array` / `tensor` read-only in device kernel | `View` HostSpace | `map(to:)` if small + proved immutable snapshot | **G-gpu** read-only witness | Avoid implicit `tofrom` |
| Host buffer written back | HostSpace | `map(tofrom:)` only with explicit `ensures` on host visibility | **G-gpu** | Default **reject** at compile time v1 |
| `lig` device buffer (Wave 13) | OpenMPTargetSpace | `map(alloc:)` / `map(to:)` | **G-gpu** device contract | Vendor alloc via OpenMP runtime |
| Stack scalars captured | `View` scalar mirror | `map(to:)` firstprivate analog | **G-gpu** capture proof | No unproved struct capture |

**Non-goal v1:** Automatic `map` inference from borrow checker without explicit device contract.

## Host OpenMP companion (not device offload)

When a program mixes **host** `parallel for` with future **device** regions:

| Practice | Li surface | Owner issue |
|----------|------------|-------------|
| `OMP_PROC_BIND=spread`, `OMP_PLACES=threads` | `[execution] affinity_profile` / env | **#129** |
| Prefer OpenMP host backend over pthread pool when app already OpenMP | `parallel_backend = openmp_prescriptive` | **#129** |
| `mpi_ranks × team_size ≤ physical_cores` | Occupancy warning | **#129** |
| OpenMPTarget host thread team sizing | Document interaction; no silent override | **#116** + **#129** |

## Explicit non-goals

| Topic | Reason |
|-------|--------|
| Native CUDA / HIP / Metal / SPIR-V emit in `lic` | Vendor paths via `lig`; not OpenMPTarget rubric |
| Embedding Kokkos C++ runtime in Li stdlib | Li lowers to OpenMP / LLVM, not Kokkos API |
| SYCL / oneAPI / Level Zero | Watch list only (`competitive/registry.toml`) |
| `omp target` codegen before **#34** `plan-approved` | Hard gate |
| Weakening `threshold_ratio_cpp` for tier-2 GPU | Benchmarks honesty violation |
| `trusted.lean` axioms for device memory | Human-approved issues only |
| Vendor-specific `target` bug workarounds in Li semantics | Document in portability appendix; defer to runtime |

## Portability appendix (vendor runtime deferral)

Per [OSTI portability study](https://www.osti.gov/servlets/purl/2224192), OpenMP target lowering varies by toolchain (Clang vs GCC, NVIDIA vs AMD offload drivers). Li policy:

1. **Correctness** — proved kernels must pass `lic build` certificate on supported toolchain matrix (defined in **#34** implement plan).  
2. **Performance** — advisory only until **G-gpu** closed slice; no dashboard green from threshold edits.  
3. **Diagnostics** — `lic` may warn when selected `lig` backend lacks OpenMPTarget support; never silent CPU fallback in release builds without `ensures`.

## Verification hooks (implement pass)

| Artifact | Gate |
|----------|------|
| `li-tests/decorators/gpu_*` | Unchanged green; no fake target emit |
| `li-tests/parallel_codegen/` | Target smoke = compile-only after **#34** |
| `./scripts/check-doc-provability-claims.sh` | All PH/G claims linked |
| `docs/benchmarks/tier2-offload-scope.md` | Bench honesty labels |
| `benchmarks/competitive/registry.toml` | `watch` row for `kokkos_openmptarget` until tier-2 in-scope |

## Cross-references

- Plan: [2026-06-07-ph7e-kokkos-openmptarget-offload-rubric-116.md](../plans/2026-06-07-ph7e-kokkos-openmptarget-offload-rubric-116.md)  
- Tier-2 scope: [tier2-offload-scope.md](../../benchmarks/tier2-offload-scope.md)  
- Master plan §7d–7e: [2026-05-14-li-master-plan.md](../plans/2026-05-14-li-master-plan.md)  
- Provability: [provability-gaps.md](../../verification/provability-gaps.md) (**G-gpu**, **G-par**, **G-dec**)
