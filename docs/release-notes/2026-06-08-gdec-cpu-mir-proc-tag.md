# G-dec: `@cpu` MIR proc tag on `def`

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-dec  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)

## Summary (one sentence)

`@cpu` on a `def` lowers to `MirDecorator.cpu`, exposed as `lic verify mir_cpu_def=` telemetry and CI via `check-mir-cpu-decorator.sh`.

## Agent continuation (required)

1. Read: `compiler/mir/lower.cpp`, `docs/verification/provability-gaps.md` (**G-dec**), [PH-7d plan](../superpowers/plans/2026-06-07-ph-7d-g-dec-mir-elaboration.md).
2. Run: `cmake --build build --target lic` and `./scripts/check-mir-cpu-decorator.sh`.
3. Then: human merge; complements PR #1490 (`@vectorized` def → `ArraySimdScope`).
4. Blocked on: Lean **P-dec** — not this PR.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator.cpu`; `copy_decorators()` records `@cpu` | `compiler/mir/include/li/mir.hpp`, `lower.cpp` |
| CLI | `mir_cpu_def=` on `lic verify` | `compiler/lic/main.cpp` |
| CI | `check-mir-cpu-decorator.sh` | `cpu_only_ok.li` |
| Docs | **G-dec** / **G-par** exit gates in phase-07 + master plan L457 | `provability-gaps.md`, `2026-05-14-phase-07-native-hpc.md` |

## Not changed (scope fence)

- Proc `@vectorized` → body `ArraySimdScope` — **PR #1490**
- `@offload` / `@async` MIR telemetry
- Lean **P-dec** / **G-par** discharge ([#387](https://github.com/li-langverse/lic/issues/387))

## Breaking changes

None.

## Security

N/A — compile-time metadata; `decorator_exploits/` unchanged.

## Performance

N/A — no new codegen behavior.

## Downstream

N/A
