# Release notes: 2026-06-08 — execution-decorator OpenMP / MLIR map

## Summary

Upstream lowering map for `std/execution` decorators → MIR → LLVM (today) → LLVM `OpenMPIRBuilder` / MLIR `omp` dialect (target). Closes explorer gap for **PH-7e** / **G-par** ([#34](https://github.com/li-langverse/lic/issues/34)).

## Agent continuation

1. Read `docs/compiler/execution-decorator-lowering-map.md`.
2. Run: `bash scripts/check-mir-parallel-decorator.sh` (when `lic` built); `bash scripts/check-doc-provability-claims.sh`.
3. Then: optional `LI_PAR_BACKEND=openmp` OpenMPIRBuilder experiment in codegen.
4. Blocked: MLIR stage, device `@gpu` / `@offload` lowering (G-gpu).

## Changed

| Path | Change |
|------|--------|
| `docs/compiler/execution-decorator-lowering-map.md` | New normative map |
| `docs/superpowers/specs/2026-05-16-li-execution-decorators.md` | Link to map |
| `docs/language/decorators.md` | Link to map |
| `docs/compiler/build-pipeline.md` | Link to map |
| `std/execution/decorators.li` | Doc pointer comment |

## Not changed

Compiler codegen, MIR lowering, `li_rt`, OpenMPIRBuilder wiring.
