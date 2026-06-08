# Orchestrator note — performance coverage (`swarm_coverage`)

**Date:** 2026-06-04  
**Todo:** `orch-performance-coverage` (research dimension pass; not a lic plan-loop todo)  
**Run:** `swarm_observer-1780589800013` · worker `93c51046`

## Summary

Performance-oriented swarm gap pass: reconcile tier-1 benchmark registry rows with empty audit `red[]`, fix ingest syntax, document PyYAML blocker, route handoffs to `bench_improver` / `numerics_researcher` under proof-before-perf.

## Evidence

- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json` (64.8, D, `unattended_safe: false`)
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json` (64 open)
- Registry tier-1 perf: `gap-benchmark-red-matmul-naive-tier1`, `gap-benchmark-red-num-gmres-tier1`, +7 integrator/physics reds
- Audit matrix: `ecosystem-audit.json` — `red: []`, `unknown: ~130` (measurement debt, not green)

## Actions

1. Fixed `scripts/swarm-gap-ingest.py` line 229 `Path` / `verticals.toml` fallback.
2. Did **not** run successful ingest/apply — `python3-yaml` missing in runner.
3. Left 22 backlog patches from 2026-05-31 apply file intact (sim/security/studio-ui).
4. No new systemd plan loops; handoffs via `config/research-goals.yaml` (`swarm_coverage`, `numerics_sota`).

## Handoffs

| Gap ids (sample) | Agent |
|------------------|-------|
| `gap-benchmark-red-matmul-naive-tier1` | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | `numerics_researcher` |
| `gap-line-profiler-001` | `issue_planner` |
| `gap-plan-pending-sim-sim-p1-num-dot-axpy` | sim backlog → implement lane |

## Blockers

- PyYAML in runner image
- benchmarks#343–#350 CI failures (catalog honesty stack)
- Stale goal-directed snapshot (2026-05-30)

## Next

1. `ci_maintainer` — 3 incomplete CI repos  
2. Merge or collapse one PH-5b catalog PR  
3. `bench_improver` after catalog CI green — refresh tier-1 matrix evidence  
