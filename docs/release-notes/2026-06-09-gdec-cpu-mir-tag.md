# G-dec: `@cpu` MIR proc tag (partial)

**Date:** 2026-06-09  
**Gaps:** **G-dec** (Partial), **P-dec** (Partial)  
**Phase:** 7d-b  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)

## Summary

`@cpu` on `def` now lowers to `MirDecorator.cpu` and `lic verify` reports `mir_cpu_def=`. Closes the last missing builtin placement tag in the 7d-b MIR telemetry set alongside `@parallel`, `@vectorized`, and `@gpu`.

## Changed

- `compiler/mir/include/li/mir.hpp` — `MirDecorator.cpu`, `count_mir_cpu_def`
- `compiler/mir/mir.cpp`, `compiler/mir/lower.cpp`, `compiler/lic/main.cpp`
- `scripts/check-mir-cpu-decorator.sh` — wired into `contracts_discharge_corpus.sh` and `check-master-plan-gates.sh`
- `docs/verification/provability-gaps.md` — **G-dec** MIR lowering evidence
- Master plan + phase-07 7d-b–e exit gates

## Not changed

- Lean **P-dec** proofs — open
- **G-par** disjoint Lean discharge — open (policy witnesses only)

## Verify

```bash
./scripts/build.sh
./scripts/check-mir-cpu-decorator.sh
./li-tests/run_all.sh decorators decorator_exploits
```
