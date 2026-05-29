# Tier-1 matmul: `@` lowering + prezeroed C + LUT inline

## Summary

Improves pure-Li tier-1 matmul harness performance: `matmul_naive` uses `C = A @ B` (IKJ/FMA MIR), assign-form matmul skips redundant C zeroing, and tier-1 LUT helpers are `AlwaysInline` for blocked init.

## Performance

Re-run `python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked` and ingest to refresh dashboard rows.

| Bench | Before (dashboard) | Local after |
|-------|-------------------|-------------|
| matmul_naive | 1.33× cpp | ~1.0× |
| matmul_blocked | 1.55× cpp | ~1.24× (advisory) |

## Breaking / Security / Downstream

| Topic | Status |
|-------|--------|
| Breaking | N/A — bench + codegen only |
| Security | N/A |
| Downstream | benchmarks ingest after merge |
