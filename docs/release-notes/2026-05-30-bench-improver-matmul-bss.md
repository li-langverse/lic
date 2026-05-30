# Release notes: bench_improver tier-1 matmul (2026-05-30)

## Performance

- **matmul_naive** tier-1 ratio vs cpp now **≤1.2×** on local harness (MIR `mm_naive_256` + IKJ/FMA).
- **matmul_blocked** harness restored to 512³ oracle shape; codegen places ≥512² float matrices in **BSS** like C `static` buffers (~2% faster vs stack).
- Fixed `bench.py` verify timing guard when `time_command` returns `TimingStats`.

## Honesty

- Reverted 64³×512 tiled `matmul_blocked` driver that inflated Li vs cpp without matching the C kernel.

## North star

PH-5b, PH-7e — proof-before-perf; numerics verify unchanged.
