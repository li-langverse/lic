# RAJA execution policy matrix + telemetry (lic#109)

**Date:** 2026-06-08  
**Gaps:** **G-par** (doc), **G-dec** (telemetry slice)  
**Phase:** 7d, 7e

## Summary

Adds normative RAJA/Kokkos/OpenMP policy rubric docs and `lic verify` telemetry (`mir_parallel_policy=static_chunk`) for proved `@parallel` loops. Gate `check-mir-parallel-decorator.sh` asserts policy telemetry and `li_parallel_for_i64` symbol when `LI_PARALLEL=1`.

## Changed

- `docs/superpowers/plans/2026-06-07-li-raja-execution-policy-matrix.md`
- `docs/superpowers/specs/2026-06-07-li-raja-policy-portability-rubric.md`
- `docs/language/decorators.md`
- `compiler/mir/mir.cpp`, `compiler/lic/main.cpp`
- `scripts/check-mir-parallel-decorator.sh`
- `docs/verification/provability-gaps.md`

## Tests

```bash
./scripts/build.sh
./scripts/check-mir-parallel-decorator.sh
./scripts/check-mir-parallel-for-disjoint.sh
```

## Not changed

- OpenMP IR lowering (lic#34), Kokkos-class codegen (lic#15), GPU memory spaces (lic#110).
