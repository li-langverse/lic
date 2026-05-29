# perf(7e): tier-1 `matmul_blocked` fused pure-Li kernel

Fused C-oracle init, blocked 512×512 GEMM (BK=64), and vectorized checksum sink in `ArrayMatMulBlocked2DF64` codegen; large bench matrices use BSS. Dashboard ratio improved ~1.30× → ~1.25× C++ on local ingest (still advisory ≤1.2× target).

See `docs/numerics/studies/2026-05-29-matmul-blocked-codegen.md`.
