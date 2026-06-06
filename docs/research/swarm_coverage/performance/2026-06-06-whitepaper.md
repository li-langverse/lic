# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage` · **Agent:** `swarm_observer` · **Run:** `1780758592672`  
**Worker:** `f77d8326` · **Generated:** 2026-06-06  
**north_star_fit:** ecosystem, ai — PH-7e (fast after proof)

## Abstract

This pass audits swarm health through a **performance lens**: benchmark posture, near-threshold regression risk, and gap-registry routing for PH-7e / sim numerics work. The ecosystem scorecard grades **D (62.6)** with `unattended_safe=false`. Tier-1 benchmarks show **zero red rows** but five **near-threshold** MD/SIMD cases and 109 **unknown** oracles. Gap ingest/apply was unblocked during this run; 62 open registry rows remain, with six directly performance-tagged.

## Method

1. Regenerated `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`.
2. Compared briefing P0 agents vs scorecard recommendations.
3. Ran `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` after fixing ingest Path/env bugs.
4. Cross-referenced `ecosystem-audit.json` near-threshold table with open `competitor_feature` / `plan_debt` rows.
5. Sampled supervisor audit logs (`org-planner-audit.jsonl`, `org-swarm-stability-audit.jsonl`).

## Findings — performance

### Benchmark posture (2026-06-05 harness)

| Class | Count | Notes |
|-------|-------|-------|
| Green | 39 | Tier-1 passing |
| Red | 0 | No current tier-1 failures on main audit |
| Near-threshold (>1.0× vs C++) | 5 | Regression watch list |
| Unknown | 109 | No oracle — coverage debt |

**Near-threshold rows:**

| ID | ratio_vs_cpp | Risk |
|----|--------------|------|
| `simd_dot` | 1.1279 | Highest — SIMD / PH-7e |
| `md_init_fcc_mb` | 1.0199 | MD init |
| `md_longrange_ewald` | 1.0139 | Long-range MD |
| `md_integrator_verlet` | 1.0129 | Integrator |
| `md_neighbor_cell_list` | 1.0121 | Neighbor list |

### Registry — performance handoffs

Open rows with direct performance impact:

- **plan_debt:** `sim-p1-num-dot-axpy`, `sim-p1-md-neighbor-cell`, master-plan Phase 7e SIMD partial
- **competitor_feature:** `matmul_naive` tier-1 red (historical 1.73×), PH-7e catalog, Kokkos execution model, verticals.toml infra gap

Apply pipeline patched sim P1 todos into `sim-algorithm-backlog.md` this cycle.

### Swarm execution (performance of the swarm itself)

- `runs_sampled=0` — control-plane observer not persisting in org-research worker; cannot compute error rate.
- `issue_planner` blocked by GitHub 403 rate limits — delays PH-7e issue routing.
- 32 failing PRs (mostly benchmarks grade-refresh) block metrics landing on main.

## Recommendations

1. **Dispatch `bench_improver`** on the five near-threshold IDs before they flip red.
2. **Route PH-7e plan_debt** to `issue_planner` — matrix `@` and SIMD matmul remain deferred per master plan honesty.
3. **Merge gap ingest fix** so vertical stub ingest works without `BENCHMARKS_COMPETITIVE` set.
4. **Consolidate benchmarks PR stack** (#375–#382) — single green grade-refresh PR.
5. **Register unknown oracles** incrementally — prioritize MD/SIMD/QM IDs overlapping sim backlog.

## Validity

| Grade | Rationale |
|-------|-----------|
| **B-** | Fresh audit + gap apply evidence; harness data 1 day stale; worker lacks full CP persistence |

## Artifacts

- Audit digest: `/app/data/runs/swarm_observer-1780758592672.md`
- Orchestrator note: `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-06-orch-r8-performance-handoffs.md`
- Scorecard: `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- Gap actions: `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/` (staging only — repo not mounted).
