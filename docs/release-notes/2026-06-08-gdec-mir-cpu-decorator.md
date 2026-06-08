# Release notes: 2026-06-08 — gdec-mir-cpu-decorator

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-7d, G-dec  
**Author:** agent

---

## Summary (one sentence)

`@cpu` on `def` now survives MIR lowering and appears in `lic verify` telemetry (`mir_cpu_def=`), closing the parse-only gap for host placement tags in the G-dec closed slice.

## Agent continuation (required)

1. Read: `compiler/mir/include/li/mir.hpp`, `compiler/mir/lower.cpp`, `compiler/mir/mir.cpp`, `compiler/lic/main.cpp`, `docs/verification/provability-gaps.md` (**G-dec**).
2. Run: `cmake --build build --target lic -j 4`, `./scripts/check-mir-cpu-decorator.sh`, and `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh decorators decorator_exploits`.
3. Then: Tier 2 MD example with `@cpu` `@parallel` `@vectorized` on `def`; `decorator def` expansion whitelist (7d-e).
4. Blocked on: Lean **P-dec** semantics proofs; `@tpu`/`@serial`/`@async` MIR tags; decorator stack incompatibility checks.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| MIR | `MirDecorator` now carries `cpu`; `copy_decorators()` records `@cpu`. | `lic verify li-tests/decorators/cpu_only_ok.li` reports `mir_cpu_def=1`. |
| Verify telemetry | `count_mir_cpu_def` and `lic verify` output expose host placement counts. | `./scripts/check-mir-cpu-decorator.sh` exit `0`. |
| CI | Wired `check-mir-cpu-decorator.sh` into `contracts_discharge_corpus.sh` and `check-master-plan-gates.sh`. | Corpus gate exit `0`. |
| Docs | Updated **G-dec** register, phase 7d exit gates, master plan tracker. | `provability-gaps.md`, `phase-07-native-hpc.md`. |

## Not changed (scope fence)

- No new codegen path for `@cpu` (host-only remains default).
- No `decorator def` macro expansion.
- No Lean **P-dec** proofs.
- **G-par** disjoint proofs unchanged.

## Breaking changes

None.
