# Explorer digest: RAJA execution policies vs Li decorators

**Date:** 2026-05-20 (gap_explorer)  
**Issue:** [lic#109](https://github.com/li-langverse/lic/issues/109)  
**PH:** PH-7e · **G-par**

## Finding

`ecosystem-explorer.json` lists **RAJA** as `missing` for policy-based loop abstractions. Li had minimal `std/execution/decorators.li` without a portable policy matrix comparable to RAJA/Kokkos.

## Delivered (lic#109)

- [x] Policy matrix: Li decorator → RAJA → Kokkos → OpenMP — [`packages/li-parallel/docs/portability-policy-matrix.md`](../../../packages/li-parallel/docs/portability-policy-matrix.md)
- [x] Tier-1 `reduce_sum` side-by-side policy documentation (same doc, § Tier-1 example)
- [x] `lic verify` telemetry `mir_omp_parallel_for=` + gate — documents `@parallel` lowering without silent serial fallback

## External signals

- [ICS 2025 portability study](https://pssg.cs.umd.edu/assets/papers/2025-06-portability-ics.pdf)
- [Plasma physics portability (Kokkos + RAJA)](https://arxiv.org/html/2411.05009v1)
- [Kokkos execution/memory spaces](https://performanceportability.org/perfport/frameworks/kokkos/)

## Deferred

- RAJA reference harness row in competitive bench (optional parity doc only)
- GPU policy lowering (`@gpu` → `cuda_exec` / Kokkos `Cuda`) — **G-gpu**, issues [#15](https://github.com/li-langverse/lic/issues/15), [#34](https://github.com/li-langverse/lic/issues/34)
