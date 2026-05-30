# Bench improver: tier-1 matmul vector FMA codegen

## Summary

Blocked and naive 2D matmul MIR lowering now uses 4-wide vector `fmuladd` on the inner `j` dimension when shapes align. Local tier-1 benches: `matmul_naive` and `num_gmres` at parity with C++; `matmul_blocked` improved from ~1.55× to ~1.27× (still advisory gap).

## Changed

| Path | Evidence |
|------|----------|
| `compiler/codegen/emit.cpp` | Vector/scalar FMA in `ArrayMatMulBlocked2DF64` and `ArrayMatMul2DF64` IKJ loops |
| `compiler/mir/lower.cpp` | `mm_naive_256` MIR hook |
| `docs/numerics/studies/2026-05-29-tier1-matmul-codegen.md` | Evidence pack |

## Performance

Re-run ingest after merge to refresh dashboard rows.

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A |
| **Security** | N/A |
| **Performance** | Tier-1 matmul rows (see study CSV) |
| **Downstream** | `benchmarks` ingest |
