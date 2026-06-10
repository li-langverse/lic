# G-dec: `@vectorized` on `def` → `ArraySimdScope` MIR (7d-b)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-dec  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)

## Summary

`@vectorized(lanes=4)` on a `def` now wraps the procedure body in `ArraySimdScope` MIR (same core as scoped `@vectorized for`), exposed as `lic verify mir_vectorized_def_scope=` telemetry.

## Changed

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirFn.vectorized_def_scope`; proc-body `ArraySimdScope` on/off | `vectorized_def_scope_ok.li` |
| CLI | `mir_vectorized_def_scope=` on `lic verify` | `compiler/lic/main.cpp` |
| CI | `check-mir-vectorized-decorator.sh` + inherit check in parallel script | `scripts/check-mir-*-decorator.sh` |
| Docs | **G-dec** closed slice (7d-b/c) in `provability-gaps.md` | [#22](https://github.com/li-langverse/lic/issues/22) |

## Not changed

- **7d-e** `decorator def` macro expansion whitelist
- Lean **P-dec** / **G-par** Lean discharge (**#387**)
