# HPX-style async futures tier-2 physics scheduling plan (lic#112)

**Date:** 2026-06-07  
**Issue:** [lic#112](https://github.com/li-langverse/lic/issues/112)  
**PH / G:** PH-7d, PH-7e, PH-5b · G-par, G-async, G-physics

## Summary

Planning slice mapping HPX lightweight futures and continuation-based work-stealing scheduling to Li `Future[T]` + `@executor` + `@async` for tier-2 gaming physics kernels — documentation and requirements only.

## Changes

| Area | Detail |
| ---- | ------ |
| Plan | `docs/superpowers/plans/2026-06-07-li-hpx-futures-tier2-physics-scheduling.md` |
| Spec | `docs/superpowers/specs/2026-06-07-li-hpx-async-futures-surface.md` |
| Gaps | `provability-gaps.md` G-async cross-link |
| Registry | `gap-hpc-hpx-futures-tier2` evidence |

## Gates

- `./scripts/check-doc-provability-claims.sh` — exit 0

## Deferred

- Parser/`Future[T]`/`then` codegen — after human `plan-approved` on #112
- `hpx_*` reference bench column — benchmarks maintainer decision
- Distributed HPX locales — G-par-dist / human gate
