# PETSc–Kokkos execution/memory requirements (lic#28)

**Date:** 2026-05-31  
**Issue:** [lic#28](https://github.com/li-langverse/lic/issues/28)  
**PH / G:** PH-7e, PH-7d, G-par, G-gpu

## Summary

Ship normative Li-facing requirements mapping Kokkos execution/memory spaces and PETSc exascale integration patterns to Li decorators, data movement rules, async fences, and PH-7d proof attachment — without claiming compiler parity.

## Changes

| Area | Detail |
| ---- | ------ |
| Spec | `docs/superpowers/specs/2026-05-31-li-petsc-kokkos-execution-memory-model.md` |
| Cross-links | `competitive-landscape.md`, `simd-parallel.md`, `execution-surface.md` |
| Gap registry | `gap-hpc-kokkos-execution-memory-spaces` evidence updated |

## Gates

- `./scripts/check-doc-provability-claims.sh` — exit 0
- `./scripts/check-hpc-competitive.sh` — exit 0 (when benchmarks sibling present)

## Deferred

- LKIR `@gpu` lowering — [lic#15](https://github.com/li-langverse/lic/issues/15)
- Lean memory-space laws — **G-gpu**
