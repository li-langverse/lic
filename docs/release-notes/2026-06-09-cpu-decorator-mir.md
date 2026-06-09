# G-dec: `@cpu` MIR proc tag on `def`

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [#22](https://github.com/li-langverse/lic/issues/22)  
**PH / REQ:** PH-7d, G-dec (related: **G-par**)

## Summary (one sentence)

`@cpu` on a `def` lowers to `MirDecorator.cpu`, exposed as `lic verify mir_cpu_def=` telemetry and CI via `check-mir-cpu-decorator.sh`, completing the host-placement half of **7d-b** MIR proc tags alongside `@gpu`.

## Agent continuation (required)

1. Read: `compiler/mir/lower.cpp`, `docs/verification/provability-gaps.md` (**G-dec**, **G-par**), `docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md` (7d-b–e exit gates).
2. Run: `./scripts/build.sh && ./scripts/check-mir-cpu-decorator.sh && ./scripts/check-mir-{parallel,gpu,vectorized}-decorator.sh`.
3. Then: Tier 2 MD example with stacked `@cpu` `@parallel` `@vectorized` on `def`; Lean **P-dec** proofs.
4. Blocked on: Lean **P-dec** — not this PR. **G-par** structured disjoint proofs remain open (**7d-c**).

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator.cpu`; `copy_decorators()` records `@cpu`. | `lic verify li-tests/decorators/cpu_only_ok.li` reports `mir_cpu_def=1`. |
| CLI | `mir_cpu_def=` on `lic verify` | `compiler/lic/main.cpp` |
| CI | `check-mir-cpu-decorator.sh` wired into corpus + master-plan gates | `contracts_discharge_corpus.sh`, `check-master-plan-gates.sh` |
| Docs | **7d-b–e** exit gates, **G-dec**/**G-par** cross-links | `provability-gaps.md`, master plan tracker, phase-07 plan |

## Not changed (scope fence)

- No new codegen behavior for `@cpu` (host-only metadata).
- **G-par** AST policy / Lean proofs — unchanged.
- Lean **P-dec** — open.

## Breaking changes

None.

## Security

N/A — compile-time metadata; `decorator_exploits/` unchanged.

## Performance

N/A — no new codegen behavior.

## Downstream

N/A — `lig` may use `mir_cpu_def` alongside `mir_gpu_def` for placement routing.

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-7d / G-dec decorator MIR:** `@cpu` on `def` lowers to `MirDecorator.cpu` and `lic verify` reports `mir_cpu_def=`; `check-mir-cpu-decorator.sh` in 2f corpus — [2026-06-09-cpu-decorator-mir.md](docs/release-notes/2026-06-09-cpu-decorator-mir.md).
```
