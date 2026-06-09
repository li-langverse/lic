# G-dec: decorator MIR elaboration slice (7d-b/c)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-dec  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)

## Summary

Proc `@cpu`, `@parallel(disjoint=)`, and `@vectorized` on `def` now elaborate to MIR tags and `ArraySimdScope` body lowering, with `lic verify` telemetry and CI gates.

## Changed

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator.cpu`; `MirFn.vectorized_def_scope`; proc-body `ArraySimdScope` on/off | `vectorized_def_scope_ok.li`, `cpu_only_ok.li` |
| CLI | `mir_cpu_def=`, `mir_vectorized_def_scope=` on `lic verify` | `compiler/lic/main.cpp` |
| CI | `check-mir-cpu-decorator.sh`; extended parallel/vectorized scripts | `scripts/check-mir-*-decorator.sh` |
| Docs | **G-dec** / **G-par** exit gates in phase-07 + master plan L457 | `provability-gaps.md`, PH-7d plan |

## Not changed

- **7d-e** `decorator def` macro expansion whitelist
- Lean **P-dec** / **G-par** discharge ([#387](https://github.com/li-langverse/lic/issues/387))
