# perf(7e): blocked matmul SIMD FMA on vec4 store path

## Summary

`ArrayMatMulBlocked2DF64` now uses `llvm.fmuladd` on the `<4 x double>` inner update (was separate `fmul` + `fadd`). Tier-1 verify unchanged; local `matmul_blocked` ratio improved from dashboard **1.549×** to **1.294×** cpp (still above 1.2× cap — ingest + further PH-7e work tracked in study doc).

## Changed

| Path | Evidence |
|------|----------|
| `compiler/codegen/emit.cpp` | FMA vec4 in `emit_matmul2d_blocked_ijk` |
| `docs/numerics/studies/2026-05-29-tier1-matmul-blocked-codegen.md` | Before/after quality table |

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A |
| **Security** | N/A |
| **Performance** | `matmul_blocked` local 1.294× cpp (was 1.549× on dashboard); `matmul_naive` 1.056× green |
| **Downstream** | Re-run benchmarks ingest after merge |
