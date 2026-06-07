# Release note: RAJA execution policy matrix plan (lic#109)

**Date:** 2026-06-07  
**Type:** Planning / documentation only — no compiler or runtime behavior change  
**Issue:** [lic#109](https://github.com/li-langverse/lic/issues/109)

## Summary

Adds a **RAJA → Li decorator policy matrix** aligned with the ICS 2025 performance-portability rubric. Maps `@parallel`, `@vectorized`, `@serial`, `@cpu`, and `@gpu` to RAJA, Kokkos, and OpenMP equivalents; anchors on tier-1 **`reduce_sum`**; defines **no silent serial fallback** done criteria for future codegen.

## Artifacts

| Path | Role |
|------|------|
| `docs/superpowers/plans/2026-06-07-li-raja-execution-policy-matrix.md` | Implementation plan |
| `docs/superpowers/specs/2026-06-07-li-raja-policy-portability-rubric.md` | Normative RP-01…RP-06 rubric + policy matrix |

## north_star_fit

HPC performance portability · **PH-7d**, **PH-7e**, **PH-7b** · **G-par**, **G-dec**

## Gates

- `./scripts/check-doc-provability-claims.sh` exit 0
- No benchmark threshold changes

## Next steps

Human **`plan-approved`** on #109 → lic#34 / lic#15 implementers consume matrix rows; optional benchmarks RAJA doc row.
