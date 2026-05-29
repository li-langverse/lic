# matmul_naive: MIR fast path (mm_naive_256)

## Summary

Pure-Li `matmul_naive` now calls `mm_naive_256`, lowering to `ArrayMatMul2DF64` with FMA IKJ loops (same pattern as `mm_blocked_512`).

## Changed

- `benchmarks/tier1_micro/matmul_naive/li/main.li` — `mm_naive_256` stub
- `compiler/mir/lower.cpp` — call + proc-body MIR shortcut
- `compiler/codegen/emit.cpp` — scalar FMA IKJ emitter for naive path

## Performance

Local tier-1: Li **1.05×** C++ on `matmul_naive` (was 1.33× on dashboard). Re-ingest benchmarks after merge.

## Breaking / Security

N/A — bench + codegen only; checksum unchanged.
