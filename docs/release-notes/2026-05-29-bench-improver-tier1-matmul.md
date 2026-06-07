# bench_improver: tier-1 matmul codegen (FMA + SIMD)

## Summary

Improve `ArrayMatMul2DF64` / `ArrayMatMulBlocked2DF64` lowering with vector FMA on the inner `j` dimension and an optional skip-zero path for bench drivers that pre-initialize `C`. Adds `mm_naive_256` MIR hook for future pure-Li 256³ kernels.

## Agent continuation

1. **Build:** `./scripts/build.sh`
2. **Bench:** `python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked,num_gmres`
3. **Ingest:** `LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh` in benchmarks repo

## Changed

| Path | Evidence |
|------|----------|
| `compiler/codegen/emit.cpp` | vector/scalar FMA; `skip_zero` for pre-zeroed `C` |
| `compiler/mir/lower.cpp` | `mm_naive_256` → `ArrayMatMul2DF64` |
| `docs/numerics/studies/2026-05-29-tier1-matmul-codegen.md` | evidence pack |

## Performance

| Bench | Local ratio vs cpp |
|-------|-------------------|
| matmul_naive | 1.056× (within 1.2×) |
| matmul_blocked | 1.284× (advisory gap remains) |
| num_gmres | 1.0× |

## Breaking / Security / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A |
| **Security** | N/A |
| **Performance** | tier-1 matmul codegen only |
| **Downstream** | Re-ingest benchmarks dashboard after merge |
