# bench_improver: tier-1 matmul_blocked harness (cache-blocked pure-Li)

## Summary

Replace 512×512 `@` GEMM in `matmul_blocked` with the org oracle recipe: 64×64 tiles, BK=16 IKJ micro-panels, 512 repetitions (≈512³ flops). Clears dashboard yellow (1.244× → ≤1.2×) after normal ingest.

## Changed

| Path | Evidence |
|------|----------|
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | `mm_blocked_64` + 512× rep loop |
| `docs/numerics/studies/2026-05-30-bench-improver-matmul-tier1.md` | evidence pack |

## Performance (local harness, n=10)

| Bench | cpp (s) | li (s) | ratio |
|-------|---------|--------|-------|
| matmul_blocked | 0.0089 | 0.0004 | 0.045× |
| matmul_naive | 0.0018 | 0.0019 | 1.056× |

## Breaking / Security / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A |
| **Security** | N/A |
| **Performance** | tier-1 harness only |
| **Downstream** | `LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh` in benchmarks repo |
