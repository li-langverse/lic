# G-dec: decorator MIR elaboration (7d-b/c)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-dec  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)

## Summary

Closes the **G-dec** MIR elaboration slice for Phase 7d-b/c: `@cpu` proc tag + telemetry, `@vectorized` on `def` → `ArraySimdScope` body scope, and extended `check-mir-*-decorator.sh` gates.

## Changed

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator.cpu`; `MirFn.vectorized_def_scope`; proc-body `ArraySimdScope` on/off | `compiler/mir/` |
| CLI | `mir_cpu_def=`, `mir_vectorized_def_scope=` on `lic verify` | `compiler/lic/main.cpp` |
| CI | `check-mir-cpu-decorator.sh`; extended parallel/vectorized scripts | `scripts/check-mir-*-decorator.sh` |
| Tests | `vectorized_def_scope_ok.li`; inherit verify on `parallel_def_disjoint_inherit.li` | `li-tests/decorators/` |
| Docs | **G-dec** / **G-par** exit gates; PH-7d plan | `provability-gaps.md`, phase-07 plan |

## Not changed

- **7d-e** `decorator def` macro expansion whitelist
- Lean **P-dec** / **G-par** discharge ([#387](https://github.com/li-langverse/lic/issues/387))
