# Release note: Chapel 2.8 HPC portability rubric plan (lic#113)

**Date:** 2026-06-07  
**Type:** Planning / documentation only — no compiler or runtime behavior change  
**Issue:** [lic#113](https://github.com/li-langverse/lic/issues/113)

## Summary

Adds a **Chapel 2.8 → Li portability checklist** for `std/execution` decorators and tier-2 physics kernels. Extracts six release signals (RISC-V/qthreads, ROCm 6.3/7, LLVM 21, Slurm launcher flags, CLS/Mason tooling, EX docs) into normative rubric rows **without adopting Chapel runtime**.

## Artifacts

| Path | Role |
|------|------|
| `docs/superpowers/plans/2026-06-07-li-chapel-28-hpc-portability-rubric.md` | Implementation plan |
| `docs/superpowers/specs/2026-06-07-li-chapel-28-portability-checklist.md` | Normative CP-01…CP-06 checklist |

## north_star_fit

HPC portability reference · **PH-7d**, **PH-7e**, **PH-5b** · **G-par**, **G-gpu**, **G-ai** (doc cross-link to lic#54)

## Gates

- `./scripts/check-doc-provability-claims.sh` exit 0
- No benchmark threshold changes

## Next steps

Rubric v1 shipped on PR #1038. Backend implementers consume rows via lic#109, lic#110, lic#54 sibling tracks.
