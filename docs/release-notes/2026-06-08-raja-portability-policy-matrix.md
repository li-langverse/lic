# PH-7e: RAJA/Kokkos portability policy matrix (lic#109)

**Date:** 2026-06-08  
**Gaps:** **G-par**, **PH-7e**  
**Issue:** [lic#109](https://github.com/li-langverse/lic/issues/109)

## Summary

Documents Li execution decorator → RAJA → Kokkos → OpenMP policy mapping, adds `reduce_sum` tier-1 side-by-side example, and exposes `mir_omp_parallel_for=` verify telemetry so `@parallel` lowering is auditable (no silent serial fallback).

## Changed

- `packages/li-parallel/docs/portability-policy-matrix.md` — policy matrix + `reduce_sum` example
- `docs/ecosystem/explorer-digests/2026-05-20-explorer-raja-policies.md` — explorer digest
- `compiler/mir/mir.cpp`, `compiler/lic/main.cpp` — `mir_omp_parallel_for=` telemetry
- `scripts/check-mir-parallel-decorator.sh` — requires `mir_omp_parallel_for=1`
- `std/execution/decorators.li` — doc cross-link

## Test plan

```bash
./scripts/build.sh
./scripts/check-mir-parallel-decorator.sh
./li-tests/run_all.sh decorators
```

## Not changed

- GPU policy lowering (**G-gpu**) — `@gpu` remains MIR placement tag only
- RAJA reference harness dependency — documentation only
