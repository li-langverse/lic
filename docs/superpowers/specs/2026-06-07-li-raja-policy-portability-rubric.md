# RAJA policy portability rubric (normative v1 slice)

**Date:** 2026-06-07  
**Status:** Planning / documentation — no codegen in this slice  
**Issue:** [lic#109](https://github.com/li-langverse/lic/issues/109)  
**Provability:** **G-par** (shared), **G-dec** (elaboration), **G-gpu** (device rows doc-only)  
**Plan:** [RAJA execution policy matrix](../plans/2026-06-07-li-raja-execution-policy-matrix.md)

## Purpose

RAJA provides **policy-based loop abstractions** (execution policies + optional reduction/scan policies) that compose across CUDA, HIP, OpenMP, and serial backends. Li’s `std/execution` decorators elaborate at compile time to MIR — this rubric maps Li surfaces to RAJA/Kokkos/OpenMP equivalents so **PH-7e** lowering and **G-par** honesty checks have an external portability baseline (ICS 2025 rubric).

**Reference only** — Li does not link RAJA. Rows inform codegen design tracked on **lic#34** (OpenMP IR) and **lic#15** (Kokkos-class lowering).

## Axes (do not conflate)

| Axis | Owner issue | This rubric (#109) |
|------|-------------|-------------------|
| Loop **execution policy** (seq/par/simd/device) | **#109** | RP-01…RP-03 matrix |
| **Memory space** / View layout | **lic#110** | Cross-link only |
| OpenMP IR **lowering** implementation | **lic#34** | Prescriptive vs descriptive notes |
| Platform / launcher portability | **lic#113** | Orthogonal |

## Checklist rows

| ID | ICS 2025 / RAJA signal | Li acceptance criterion | Status | PH / G | Notes |
|----|------------------------|-------------------------|--------|--------|-------|
| **RP-01** | Policy composability (RAJA `Policy` template parameter) | Document Li decorator stacks as **ordered policy list** elaborating to MIR tags | Partial (doc) | PH-7d, **G-dec** | Top-to-bottom stack in source |
| **RP-02** | Host parallel policies (`omp_parallel_for_exec`, `loop_exec`) | `@parallel(disjoint=…)` → static OpenMP team + chunk; **no silent serial** when parallel enabled | Partial (doc) | PH-7b, **G-par** | Implementation: lic#34 |
| **RP-03** | SIMD / vector policies (`simd_exec`) | `@vectorized(lanes=N)` → LLVM intrathread vectors; never spawns `li_parallel_for_*` | Partial (doc) | PH-7e, **G-par** | Separate from OS parallelism |
| **RP-04** | Reduction policies (`ReduceSum`, `ReduceMax`, …) | Tier-1 **`reduce_sum`** anchor doc: four-framework side-by-side | Partial (doc) | PH-7e, **G-math** | Perf ratios on lic#463 |
| **RP-05** | Device policies (`cuda_exec`, `hip_exec`) | `@gpu` rows map to device execution space; codegen stub until **lic#110** | Partial (doc) | PH-7e, **G-gpu** | No CUDA/HIP emit in v1 |
| **RP-06** | Portability study parity (Kokkos/RAJA/OpenMP/SYCL) | Competitive registry `raja` watch row + quarterly review | Partial (doc) | PH-7e | `registry.toml` bump |

## Policy matrix (normative)

| Li surface | RAJA policy (reference) | Kokkos policy (reference) | OpenMP construct / schedule | Li v1 target | Proof gate |
|------------|---------------------------|----------------------------|-----------------------------|--------------|------------|
| (none) serial `for` | `RAJA::seq_exec` | `Kokkos::Serial`, `RangePolicy(0,N)` | serial loop | Serial MIR | N/A |
| `@serial` on `for` | `RAJA::seq_exec` | `Kokkos::Serial` | `omp single` / no team | Force serial MIR | **G-dec** |
| `parallel for` + `@parallel(disjoint=d)` | `RAJA::omp_parallel_for_exec` | `Kokkos::OpenMP`, `RangePolicy` | `#pragma omp parallel for schedule(static)` | `li_parallel_for_*` static chunk | **G-par** disjoint |
| `@vectorized(lanes=N)` | `RAJA::simd_exec` | vector width on host range | `#pragma omp simd` (descriptive) | LLVM `<N x T>` | bounds + disjoint inner |
| `@parallel` + `@vectorized` (stacked) | outer `omp_parallel_for_exec`, inner `simd_exec` | nested `parallel_for` + SIMD | parallel outer + simd inner | PH-7e prescriptive/descriptive split | both gates |
| `@cpu` | host tag (default) | default host ES | host team | default placement | **G-dec** |
| `@gpu` | `RAJA::cuda_exec` / `RAJA::hip_exec` | `Kokkos::Cuda` / `Kokkos::HIP` | `target teams distribute` (watch) | MIR `@gpu` tag only | **G-gpu** |
| `@async` | task graph policies (watch) | Kokkos tasking (watch) | OpenMP `task` (watch) | defer to **lic#125** | **G-par** future |

### Prescriptive vs descriptive (OpenMP)

| Li intent | OpenMP role | Owner |
|-----------|-------------|-------|
| `@parallel` team + chunk size | **Prescriptive** — compiler emits `parallel for schedule(static, chunk)` | lic#34 |
| `@vectorized(lanes=N)` | **Descriptive** — `simd` hint when proofs allow; LLVM may ignore | PH-7e metadata |
| User `schedule=` knob (future) | Explicit policy enum mapped to RAJA `Auto`, `Static`, `Dynamic` | post-v1 |

## RP-04 — Tier-1 anchor: `reduce_sum`

Harness: `benchmarks/harness/bench.py --tier 1 --only reduce_sum`, `reduce_sum_parallel` in execution resource sweep.

### Li (target surface)

```li
@parallel(disjoint=disjoint_idx)
parallel for i in 0..<n
  requires disjoint_idx(i, acc)
  acc += xs[i]
```

Expected MIR: `ParallelFor` → `li_parallel_for_i64` + reduction tree (`li_par_reduce_sum_f64`). Policy telemetry: `mir_parallel_policy=static_chunk`.

### RAJA (reference pseudocode)

```cpp
using Pol = RAJA::omp_parallel_for_exec;
RAJA::ReduceSum<RAJA::omp_reduce, double> rsum(0.0);
RAJA::forall<Pol>(RAJA::RangeSegment(0, n), [=](int i) { rsum += xs[i]; });
double sum = rsum.get();
```

### Kokkos (reference pseudocode)

```cpp
double sum = 0.0;
Kokkos::parallel_reduce(
  "reduce_sum", Kokkos::RangePolicy<>(0, n),
  KOKKOS_LAMBDA(const int i, double& lsum) { lsum += xs[i]; }, sum);
```

### OpenMP (reference)

```cpp
double sum = 0.0;
#pragma omp parallel for reduction(+:sum) schedule(static)
for (int i = 0; i < n; ++i) sum += xs[i];
```

**Parity doc rule:** Optional **benchmarks** row may cite RAJA driver timing for documentation; Li `threshold_ratio_cpp` unchanged.

## No silent serial fallback (RP-02 detail)

When **all** of the following hold:

1. Source uses `@parallel(disjoint=…)` or `parallel for` with valid disjoint proof,
2. Build enables parallelism (`LI_PARALLEL=1`, `--cores>1`, or `[execution] cores > 1`),
3. Target supports OpenMP (host tier-1),

Then **lic** must either:

- Emit documented parallel policy (RP-02 row), **or**
- **Fail at compile time** with explicit diagnostic (`E-par-no-backend` or successor),

and **must not** silently lower to serial loop.

Windows: Win32 thread pool path (see [parallel design spec](2026-06-06-li-parallel-design.md)) — still not serial when parallel requested.

## Learned from

| Source | Li adaptation |
|--------|---------------|
| [ICS 2025 portability paper](https://pssg.cs.umd.edu/assets/papers/2025-06-portability-ics.pdf) | Six-framework parity rubric; Li v1 host OpenMP only |
| [RAJA user guide — execution policies](https://raja.readthedocs.io/en/develop/sphinx/user_guide/exec_policies.html) | RP-01…RP-05 row names |
| [Kokkos programming model](https://performanceportability.org/perfport/frameworks/kokkos/) | Execution space column |
| Li parallel design spec | Axes separation (SIMD ≠ parallel ≠ device) |

## Verification

- `./scripts/check-doc-provability-claims.sh` — no proof-certificate overclaim
- `./scripts/check-hpc-competitive.sh` — registry consistency after RAJA row
- Cross-links: lic#34, lic#15, lic#110, lic#113 remain distinct scopes
