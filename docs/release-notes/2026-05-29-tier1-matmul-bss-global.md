# Tier-1 matmul: 512² matrices in BSS globals

## Summary

Codegen places `512×512` bench matrices in internal linkage globals instead of multi-megabyte stack allocas, matching the C++ `static` buffer layout in `matmul_blocked_core.c`.

## Agent continuation

1. Re-run `python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked`.
2. Open PR; cite local CSV rows; run full tier-1 ingest on CI (do not ingest from partial `latest.csv`).

## Changed

| Path | Evidence |
|------|----------|
| `compiler/codegen/emit.cpp` | `ArraySlot`, `kBenchMatrixGlobalElems`, BSS `ArrayAlloc` |
| `docs/numerics/studies/2026-05-29-tier1-matmul-bench-improver.md` | evidence pack |

## Performance

| Bench | Local ratio vs cpp |
|-------|-------------------|
| `matmul_naive` | 1.00× |
| `matmul_blocked` | 1.26× (advisory gap remains) |
