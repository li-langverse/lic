# std::execution sender/receiver tier-2 scheduling plan (lic#125)

**Date:** 2026-06-07  
**Issue:** [lic#125](https://github.com/li-langverse/lic/issues/125)  
**PH / G:** PH-7d, PH-7e, PH-5b · G-par, G-async, G-ai

## Summary

Maps C++26 P2300 sender/receiver semantics to Li `@schedule` decorators and structured `when_all` concurrency for tier-2 gaming physics kernels (lic#125). Includes plan/spec docs plus a minimal compiler slice: policy validation, MIR telemetry, and `when_all` borrow-conflict gate.

## Changes

| Area | Detail |
| ---- | ------ |
| Plan | `docs/superpowers/plans/2026-06-07-li-stdexecution-sender-receiver-tier2-scheduling.md` |
| Spec | `docs/superpowers/specs/2026-06-07-li-sender-receiver-async-scheduling-surface.md` |
| Compiler | REQ-7d `@schedule(task\|par\|par_unseq)` policy + MIR tag stub; `when_all` borrow gate |
| Tests | `li-tests/decorators/schedule_*.li`, `li-tests/effects/when_all_*.li` |
| Gaps | `provability-gaps.md` G-async cross-link |
| Registry | `gap-hpc-stdexecution-sender-receiver` evidence |

## Gates

- `./scripts/check-doc-provability-claims.sh` — exit 0
- `lic verify li-tests/decorators/schedule_task_ok.li` — `mir_schedule_def=1`
- `lic diagnose li-tests/effects/when_all_conflicting_var_fail.li` — E0310
- `./li-tests/run_all.sh decorators` / `effects` — CI green on PR #1159

## Deferred

- `await`/`when_all` MIR codegen + `li_async_poll` lowering
- `stdpar` reference bench column — benchmarks maintainer decision
- LKIR device graphs — G-gpu / lic#15
