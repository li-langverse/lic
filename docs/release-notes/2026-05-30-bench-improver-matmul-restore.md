# bench_improver: restore tier-1 matmul MIR fast paths

**2026-05-30** — Reverts accidental `C = A @ B` regression on `matmul_naive` / `matmul_blocked` drivers; restores IKJ + `mm_blocked_512` hooks. LLVM matmul loops use PHI induction for better clang opt.

## Performance (local harness)

| Bench | Dashboard before | Local after |
|-------|------------------|-------------|
| matmul_naive | 1.333× | **1.000×** |
| matmul_blocked | 1.549× | **1.291×** (still advisory; ingest should improve row) |

## Agent continuation

1. Merge lic PR; re-run benchmarks ingest on CI agent host.
2. If `matmul_blocked` stays >1.2×: static-buffer parity or micro-kernel proof (human review).

## Changed

| Path | Role |
|------|------|
| `benchmarks/tier1_micro/matmul_naive/li/main.li` | IKJ hot loop |
| `benchmarks/tier1_micro/matmul_blocked/li/main.li` | `mm_blocked_512` |
| `compiler/codegen/emit.cpp` | PHI loop induction in matmul emit |
| `docs/numerics/studies/2026-05-30-bench-improver-matmul-restore.md` | evidence |
