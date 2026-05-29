# perf(codegen): blocked GEMM FMA + 8-wide SIMD for tier-1 `matmul_blocked`

Pure-Li `matmul_blocked` (`mm_blocked_512` / `ArrayMatMulBlocked2DF64`) uses vector `llvm.fmuladd` and 8-wide `j` inner steps when BK=64.

**Verify:** `python3 benchmarks/harness/bench.py --tier 1 --only matmul_blocked --verify-results --skip-verify`

**Timing:** expect Li/cpp ratio to move from ~1.30× toward ~1.25× on the same machine; org ingest required for dashboard green (≤1.2×).

**PH:** PH-5b, PH-7e (partial)
