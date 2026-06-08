# G-dec: @cpu MIR proc tag + 7d exit gates (partial)

**Date:** 2026-06-08  
**Gaps:** **G-dec** (Partial), **P-dec** (Partial)  
**Phase:** 7d, 2f  
**Issue:** li-langverse/lic#22

## Summary

Adds `@cpu` host-placement MIR proc tag (`MirDecorator.cpu`) and `lic verify` telemetry (`mir_cpu_def=`), wires `check-mir-cpu-decorator.sh` into the 2f discharge corpus, and updates provability-gaps + master-plan 7d-b–e exit gates to reflect existing decorator MIR lowering.

## Agent continuation

1. Read `docs/verification/provability-gaps.md` (**G-dec**, **G-par**).
2. Run `./scripts/build.sh && ./scripts/check-mir-cpu-decorator.sh && ./scripts/check-mir-parallel-decorator.sh && ./scripts/check-mir-vectorized-decorator.sh && ./scripts/check-mir-gpu-decorator.sh`.
3. Blocked: Lean **P-dec** proofs; Tier 2 MD example with stacked `@cpu` `@parallel` `@vectorized` on `def`.

## Changed

- `compiler/mir/include/li/mir.hpp`, `compiler/mir/mir.cpp`, `compiler/mir/lower.cpp`, `compiler/lic/main.cpp`
- `scripts/check-mir-cpu-decorator.sh`
- `li-tests/tooling/contracts_discharge_corpus.sh`, `scripts/check-master-plan-gates.sh`
- `docs/verification/provability-gaps.md`, master plan, phase-07 plan, `docs/language/decorators.md`

## Not changed

- Lean **P-dec** — open.
- **G-par** AST policy / Lean proofs — unchanged.
- Tier 2 MD stacked-decorator example — open.

## Breaking / Security / Performance / Downstream

N/A — telemetry-only addition for `@cpu`.
