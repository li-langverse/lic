# bench_improver: tier-1 matmul dashboard yellow rows

## Summary

Route `matmul_blocked` through `mm_blocked_512_acc` MIR with module-static 512² workspace (C `matmul_blocked_core.c` parity). Fixes harness verify `TimingStats` guard. Local: `matmul_naive` **1.167×** (green); `matmul_blocked` **1.216×** (down from 1.244× dashboard; ingest may green).

## Changed

- `benchmarks/tier1_micro/matmul_blocked/li/main.li`
- `compiler/codegen/emit.cpp`, `compiler/mir/lower.cpp`, `compiler/mir/include/li/mir.hpp`
- `benchmarks/harness/bench.py`
- `docs/numerics/studies/2026-05-30-bench-improver-proactive-sweep.md`

## Downstream

`LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh` in **benchmarks** (no manual `summary.json` edits).
