# Orchestrator note — Eigen numerics reference policy (math-r)

**Date:** 2026-06-07  
**Agent:** `issue_planner` · worker `7d359d55`  
**Issue:** [lic#33](https://github.com/li-langverse/lic/issues/33)  
**Plan:** [2026-06-07-eigen-numerics-reference-policy.md](../../superpowers/plans/2026-06-07-eigen-numerics-reference-policy.md)

## north_star_fit

Scientific computing / dense LA — **PH-5b**, **PH-7e**, **G-math**; proof-first reference honesty before perf; no `threshold_ratio_cpp` weakening.

## Handoff queue (post plan-approved)

| Agent | Branch / lane | First WP |
|-------|---------------|----------|
| `code_implementer` | `cursor/numerics-reference-loop` | wp-math-r1-backlog, wp-math-r3-gate-script |
| `code_implementer` | benchmarks sibling PR | wp-math-r2-pinned-md |
| `numerics_researcher` | optional | wp-math-r7-eigen5-migration-gate |

## Blockers

- Human **`plan-approved`** on #33 before implementation.
- Draft plan PR — do not self-merge.

## Related (do not duplicate)

- [benchmarks#27](https://github.com/li-langverse/benchmarks/issues/27) — multi-vendor cadence
- [lic#463](https://github.com/li-langverse/lic/issues/463) — tier-1 red codegen closure
