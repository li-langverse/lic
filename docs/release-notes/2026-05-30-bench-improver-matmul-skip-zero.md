# bench_improver: matmul assignment skip-zero + 8-wide FMA (N≤256)

## Summary

Tier-1 `matmul_naive` drops below the 1.2× C++ advisory cap by skipping redundant zeroing on `C = A @ B` when `C` is already initialized, and by using 8-wide `llvm.fmuladd` on the inner dimension for 256×256.

## Changed

| Path | Evidence |
|------|----------|
| `compiler/mir/lower.cpp` | `push_matmul2d`; assignment `use_loaded_int` |
| `compiler/codegen/emit.cpp` | 8-wide FMA when `n ≤ 256` |
| `docs/numerics/studies/2026-05-30-bench-improver-matmul-skip-zero.md` | evidence pack |

## Performance

| Bench | Local ratio vs cpp |
|-------|-------------------|
| matmul_naive | **1.056×** (within 1.2×) |
| matmul_blocked | ~1.45× (follow-up: blocked MIR + stack vs static) |

## Breaking / Security / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A |
| **Security** | N/A |
| **Performance** | tier-1 matmul codegen only |
| **Downstream** | Re-ingest benchmarks dashboard after merge |
