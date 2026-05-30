# Bench improver: matmul oracle init in codegen

Tier-1 `matmul_naive` and `matmul_blocked` pure-Li drivers no longer use `mm_lut_*` if-chains for matrix fill. The compiler emits C-oracle init via `SIToFP` inside `mm_naive_256` / `mm_blocked_512` MIR hooks. Naive 256³ GEMM uses scalar IKJ loops (not blocked tiles).

**Verify:** `python3 benchmarks/harness/bench.py --tier 1 --only matmul_naive,matmul_blocked --runs 5`
