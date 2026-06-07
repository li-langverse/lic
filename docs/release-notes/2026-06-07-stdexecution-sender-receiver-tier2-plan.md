# std::execution sender/receiver tier-2 scheduling plan (lic#125)

**Date:** 2026-06-07  
**Issue:** [lic#125](https://github.com/li-langverse/lic/issues/125)  
**PH / G:** PH-7d, PH-7e, PH-5b · G-par, G-async, G-ai

## Summary

Planning slice mapping C++26 P2300 sender/receiver semantics to Li `@schedule` decorators and structured `when_all` concurrency for tier-2 gaming physics kernels — documentation and requirements only.

## Changes

| Area | Detail |
| ---- | ------ |
| Plan | `docs/superpowers/plans/2026-06-07-li-stdexecution-sender-receiver-tier2-scheduling.md` |
| Spec | `docs/superpowers/specs/2026-06-07-li-sender-receiver-async-scheduling-surface.md` |
| Gaps | `provability-gaps.md` G-async cross-link |
| Registry | `gap-hpc-stdexecution-sender-receiver` evidence |

## Gates

- `./scripts/check-doc-provability-claims.sh` — exit 0

## Deferred

- Parser/`await`/`when_all` codegen — after human `plan-approved` on #125
- `stdpar` reference bench column — benchmarks maintainer decision
- LKIR device graphs — G-gpu / lic#15
