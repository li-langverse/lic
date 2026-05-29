# Tier-1 `matmul_blocked` codegen — vector FMA + 512×64 tile schedule

## Summary

Blocked pure-Li matmul (`mm_blocked_512` MIR) now uses vector `fmuladd` on the inner `j` loop, a constant 8×8×8 tile schedule for 512³/BK=64, and raised `@` unroll cap (64³). Local tier-1 check: **matmul_blocked 1.193×**, **matmul_naive 1.053×** vs cpp (cap 1.2×).

## Agent continuation

1. Merge lic PR; run benchmarks ingest for dashboard refresh.
2. Track `num_gmres` / `ml_*` on li-math or pure-Li Krylov follow-ups.

## Changed

| Path | Note |
|------|------|
| `compiler/codegen/emit.cpp` | blocked + IKJ SIMD/FMA; 512/64 fast tile path |
| `compiler/mir/lower.cpp` | `mm_naive_256` hook (optional) |
| `docs/numerics/studies/2026-05-29-tier1-matmul-blocked-codegen.md` | evidence pack |

## Performance

Re-run `python3 benchmarks/harness/bench.py --tier 1` after merge; ingest `benchmarks` repo — do not hand-edit `summary.json`.
