# Swarm coverage — performance dimension (2026-06-04)

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**north_star_fit:** ecosystem orchestration for proof-before-perf bench gaps (PH-5b, PH-7e)

## Thesis

The swarm can route performance work only when **measurement and registry agree**. Today the gap registry lists nine tier-1 competitor-feature rows (matmul, GMRES, integrators), while `ecosystem-audit.json` reports `red: []` and a large `unknown` set — so dispatch priority must be **instrumentation + catalog honesty** before codegen/SIMD pushes.

## Signals (2026-06-04)

| Signal | Value | Source |
|--------|-------|--------|
| Ecosystem grade | D (64.8) | `ecosystem-quality-report.json` |
| Open perf-related gaps | 9 tier-1 `competitor_feature` + sim plan_debt (dot/axpy, qm-dft) | `registry.yaml` |
| Bench matrix reds | 0 | `ecosystem-audit.json` |
| Bench matrix unknown | ~130 workloads | `agent-briefing.json` ecosystem_audit |
| Master plan partial | Phase 7e SIMD matmul deferred | `registry.yaml` plan_debt rows |

## Tier-1 registry rows (handoff queue)

1. `gap-benchmark-red-matmul-naive-tier1` — 1.73× vs cpp (PH-7e)  
2. `gap-benchmark-red-num-gmres-tier1` — 1.68× vs cpp (PH-5b)  
3. `gap-benchmark-red-num-opt-line-search-tier1` — 2.00× vs cpp  
4. `gap-benchmark-red-num-integ-euler-tier1`, `num-integ-verlet`  
5. `gap-benchmark-red-cloth-swing-tier1`, `orbit-two-body`, `schrodinger-1d-barrier`  

**Agents:** `bench_improver` (harness/evidence), `numerics_researcher` (algorithm proof path). No `unsafe` / unproved fast paths.

## Orchestration gaps affecting perf measurement

- `swarm-gap-ingest.py` blocked without PyYAML → vertical stub ingest stale  
- `gap-infra-verticals-toml-missing-benchmarks-main` — blocks honest vertical ingest on main  
- Failed benchmarks PR wave (#343–#350) — blocks refreshed grade/actions on main  

## Recommendations

1. Unblock gap pipeline (`python3-yaml` + ingest syntax — latter fixed 2026-06-04).  
2. Land one PH-5b catalog honesty PR; close redundant stack.  
3. Run tier-1 harness refresh → populate `ecosystem-audit.json` `red`/`green` from evidence, not stubs.  
4. Enqueue `numerics_sota` research goal for Kokkos/OpenMP rubric rows after matrix honest.  

## Related

- Orchestrator: `docs/ecosystem/orchestrator-notes/2026-06-04-orch-performance-coverage.md`  
- Swarm report: `li-cursor-agents/data/runs/swarm_observer-1780589800013.md`  
- Architecture: `docs/ecosystem/swarm-architecture.md`  

_Publish target (when mounted): `research-findings/whitepapers/2026-06/swarm_coverage/performance/`_
