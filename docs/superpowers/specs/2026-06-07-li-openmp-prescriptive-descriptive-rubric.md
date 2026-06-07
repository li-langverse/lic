# OpenMP prescriptive vs descriptive divergent-branch rubric

**Date:** 2026-06-07  
**Status:** Normative (Phase 0 — policy + docs; codegen Phase 2 blocked on [#34](https://github.com/li-langverse/lic/issues/34))  
**Plan:** [2026-06-07-ph7e-openmp-prescriptive-descriptive-divergent-branch-rubric-124.md](../plans/2026-06-07-ph7e-openmp-prescriptive-descriptive-divergent-branch-rubric-124.md)  
**Depends on:** [Execution surface](2026-05-25-li-execution-surface.md), [Execution decorators](2026-05-16-li-execution-decorators.md)  
**Issues:** [#124](https://github.com/li-langverse/lic/issues/124), complements [#15](https://github.com/li-langverse/lic/issues/15), [#34](https://github.com/li-langverse/lic/issues/34), [#116](https://github.com/li-langverse/lic/issues/116), [#129](https://github.com/li-langverse/lic/issues/129)  
**North star fit:** HPC/scientific computing (**PH-7e**, **G-par**) — proof-before-perf; prescriptive and descriptive variants require the same `disjoint=` proofs.

## Terms

| Variant | Who decides parallelism | Typical OpenMP codegen | Competitive when |
|---------|-------------------------|------------------------|------------------|
| **Prescriptive** | User / compiler emits explicit directives | `#pragma omp target teams distribute parallel for simd` | Vendor offload tuned; known trip counts; SIMD inner loops |
| **Descriptive** | Compiler discovers parallelism from loop structure | `#pragma omp parallel for` (auto schedule), auto-vectorization | Host CPU with mature LLVM loop opts; irregular control flow |
| **Divergent branch** | Runtime / build-time backend fork | Kokkos execution-space dispatch; separate CUDA/HIP/SYCL vs OpenMP host TU | Heterogeneous clusters; GPU nodes with host fallback |

## §A — Prescriptive vs descriptive selection

| Signal | Prescriptive (directive-driven) | Descriptive (compiler-discovered) | Proof requirement |
|--------|--------------------------------|-----------------------------------|-------------------|
| `@cpu(openmp=prescriptive)` or `li.toml [execution] parallel_style = "prescriptive"` | Emit explicit `#pragma omp` stack | — | Same `disjoint=` as descriptive |
| Regular loop, known trip count, inner `@vectorized` | `teams distribute parallel for` + `simd` on inner | Auto-vec outer + `parallel for` | SIMD scope proof (**G-math** partial) |
| Irregular control flow, indirect indexing | — | `parallel for` + auto schedule | Stronger disjoint proof or reject |
| GPU offload intent (`@gpu`, `@cpu(openmp=target)`) | OpenMP **target** prescriptive stack | Reject descriptive-only on device | **#116** offload proof track |
| Default / `@cpu(openmp=auto)` | Prefer descriptive on host pthread/OpenMP path until #34 IR green | Same | Auto must log chosen variant in `lic build -v` |

**Policy (v1):** `@cpu(openmp=…)` accepts `prescriptive`, `descriptive`, `auto`, or `target`. `@parallel(schedule=…)` accepts `static`, `auto`, or `dynamic`. `@cpu(openmp=descriptive)` with `@gpu` on the same `def` is a **compile error** (offload requires prescriptive or target).

## §B — Divergent backend branches

| Condition | Branch hook | Li surface | Verification |
|-----------|-------------|------------|--------------|
| Host-only build (`--target=host`) | Single TU, descriptive or prescriptive per §A | `@cpu` default | `li-tests/execution/openmp_rubric/host_only.li` |
| Heterogeneous manifest (`[execution] backends = ["openmp_host", "cuda"]`) | **Divergent TU** per backend; shared proved MIR | `@gpu(devices=N)` + `@cpu(openmp=prescriptive)` on host fallback | Compile-only fixtures per backend |
| Kokkos-style execution space | Dispatch table in `runtime/li_exec_dispatch.c` (future) | Maps to `@cpu`, `@gpu`, `@parallel` stack | Golden dispatch log in CI |
| Competitive perf requires vendor tweak | Documented **opt-in** branch (`LI_EXEC_PRESCRIPTIVE=1`) | Never silent; stderr once | Bench CSV `openmp_variant` column |

## §C — Decorator → execution-space mapping (Kokkos analog)

| Li decorator stack | Kokkos analog | OpenMP prescriptive | OpenMP descriptive |
|--------------------|---------------|---------------------|-------------------|
| `@cpu` `@parallel` | `Kokkos::OpenMP` / `DefaultHostExecutionSpace` | `#pragma omp parallel for schedule(static)` | `#pragma omp parallel for` (auto) |
| `@cpu` `@parallel` `@vectorized(lanes=4)` | OpenMP + SIMD on inner | `parallel for simd` inner + teams outer if tiled | Auto-vec + `parallel for` |
| `@gpu(devices=N)` | `Kokkos::Cuda` | N/A (CUDA branch) | N/A |
| `@cpu(openmp=target)` | `Kokkos::OpenMPTarget` | `#pragma omp target teams distribute parallel for` | Reject — target requires prescriptive |
| `@serial` | `Kokkos::Serial` | No OpenMP | No OpenMP |

## Decision flow (summary)

```mermaid
flowchart TD
  A["@parallel / parallel for + disjoint="] --> B{Backend intent?}
  B -->|@gpu or openmp=target| C["Prescriptive target stack (#116)"]
  B -->|Host only| D{openmp= knob?}
  D -->|prescriptive| E["Explicit teams/SIMD pragma stack"]
  D -->|descriptive / auto| F["Compiler-discovered parallel for"]
  D -->|auto default| F
  C --> G["Same G-par disjoint proofs"]
  E --> G
  F --> G
```

## Benchmark annotation (Phase 3 — benchmarks repo)

Tier-2 CSV columns (documented here; harness lands in benchmarks repo):

| Column | Values | Meaning |
|--------|--------|---------|
| `openmp_variant` | `prescriptive`, `descriptive`, `auto` | Which §A path ran |
| `execution_space` | `host_openmp`, `cuda`, `hip`, `sycl`, `openmp_target` | Backend selected |
| `divergent_branch` | `true`, `false` | Whether build used per-backend TU fork |

## Out of scope (this spec)

- LLVM OpenMP IR builder mapping — [#34](https://github.com/li-langverse/lic/issues/34)
- OpenMPTarget backend bring-up — [#116](https://github.com/li-langverse/lic/issues/116)
- Thread affinity / MPI occupancy — [#129](https://github.com/li-langverse/lic/issues/129)
- Product codegen (`compiler/codegen/openmp_variant.*`) — Phase 2 after #34

## Verification

| ID | Requirement | Test / doc |
|----|-------------|------------|
| **REQ-par-omp-variant-001** | Prescriptive vs descriptive decision table | This spec §A; [parallelism.md](../../language/parallelism.md) |
| **REQ-par-omp-branch-001** | Divergent backend hook checklist | This spec §B |
| **REQ-par-omp-kokkos-map-001** | Execution-space mapping table | This spec §C |
| **G-par** | Disjoint proofs unchanged across variants | `race_shared_memory`, `decorator_exploits`, `execution/openmp_rubric/` |

Handbook: [parallelism.md](../../language/parallelism.md). Gaps: [provability-gaps.md](../../verification/provability-gaps.md).
