# G-dec: @cpu MIR proc tag + phase-7d exit gates (partial)

**Date:** 2026-06-08  
**Gaps:** **G-dec** (Partial), **G-par** (related — disjoint witness heuristic)  
**Phase:** 7d-b–e, 2f  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)

## Summary

Completes the builtin decorator MIR proc-tag slice: `@cpu` now lowers to `MirDecorator.cpu` with `lic verify` telemetry (`mir_cpu_def=`). Updates master plan / phase-07 exit gates for 7d-b–e and syncs **G-dec** in `provability-gaps.md` (parse + policy + MIR lowering — not “parse only”).

## Agent continuation

1. Read `docs/verification/provability-gaps.md` (**G-dec**, **G-par**).
2. Run `./scripts/build.sh && ./scripts/check-mir-cpu-decorator.sh && ./scripts/check-mir-parallel-decorator.sh && ./scripts/check-mir-vectorized-decorator.sh && ./scripts/check-mir-gpu-decorator.sh`.
3. Blocked: Lean **P-dec** proofs; `@async` MIR tag; `decorator def` expansion whitelist (7d-e).

## Changed

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator.cpu`; `copy_decorators()` records `@cpu` on `def`. | `lic verify li-tests/decorators/cpu_only_ok.li` → `mir_cpu_def=1`. |
| Verify | `count_mir_cpu_def`, `mir_cpu_def=` on `lic verify`. | `./scripts/check-mir-cpu-decorator.sh` exit `0`. |
| CI | Wired `check-mir-cpu-decorator.sh` into corpus + master-plan gates. | `contracts_discharge_corpus.sh`, `check-master-plan-gates.sh`. |
| Docs | Phase 7d exit gates, **G-dec** register, execution-decorators spec. | `provability-gaps.md`, master plan § Compiler tasks vs proof gaps. |

## Not changed

- No new LLVM/OpenMP codegen for `@cpu` (host default; tag is placement metadata).
- **G-par** Lean proofs — unchanged; `disjoint=` still policy-heuristic witness.
- Lean **P-dec** — open.

## Breaking / Security / Performance / Downstream

N/A
