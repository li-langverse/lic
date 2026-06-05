# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `8b8b3a25`  
**Date:** 2026-06-05  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`  
**north_star_fit:** ecosystem control plane; PH-5b (numerics), PH-7e (SIMD/parallel lowering)

## Abstract

This pass audits whether the Li agent swarm can **orchestrate performance gaps** without human intervention. We correlate live benchmark posture (`ecosystem-audit.json`), the swarm-gap registry, and goal-directed plan debt. Main finding: **gap ingest/apply was broken** (syntax + PyYAML), masking backlog updates; after repair, **62 open gaps** remain with **zero tier-1 reds on main** but **140+ unknown** catalog rows and **stale registry red rows**.

## Method

1. Regenerate `ecosystem-quality-report.json` with `LI_CURSOR_AGENTS_ROOT=/app`.
2. Run `swarm-gap-ingest.py` + `swarm-gap-apply-actions.py` after fixing ingest L229.
3. Compare `ecosystem-audit.benchmarks` vs open `gap-benchmark-red-*` registry rows.
4. Map `plan_debt` sim/httpd todos to research-lane handoffs (no systemd loops).

## Live performance posture

| Metric | Value | Source |
|--------|-------|--------|
| Tier-1 red count (main) | 0 | `ecosystem-audit.json` |
| Green benchmarks | 39 | same |
| Near threshold | 5 (incl. `simd_dot` 1.13×) | same |
| Unknown / unmeasured | ~140 | same |
| Open perf-related registry gaps | 30 `competitor_feature` + sim/httpd `plan_debt` | `registry.yaml` |

### Near-threshold hotspots (proof-gated perf work)

| Bench id | ratio_vs_cpp | PH | Suggested owner |
|----------|--------------|-----|-----------------|
| `simd_dot` | 1.1279 | PH-7e | `bench_improver` — vectorized reduction after proof |
| `md_neighbor_cell_list` | 1.0121 | PH-5b | `numerics_researcher` — ties `sim-p1-md-neighbor-cell` |
| `md_integrator_verlet` | 1.0129 | PH-5b | `numerics_researcher` |

## Orchestration health

| Check | Pass? | Notes |
|-------|-------|-------|
| Gap ingest runs | ✅ (after fix) | Was SyntaxError L229 since ~2026-06-04 |
| Gap apply runs | ✅ (after PyYAML) | Image should bake dependency |
| Vertical stub ingest | ❌ | 0 stubs — `verticals.toml` path/main drift |
| Registry ↔ audit honesty | ❌ | 8 stale tier-1 red rows |
| Control-plane observer | ❌ | No `latest-report.json` / `state.json` |
| Unattended safe | ❌ | Grade C; 37 failing PRs |

## Recommendations

1. **Merge catalog honesty PR** (`benchmarks#354` / #266) before further metrics churn — unblocks vertical ingest and unknown-row closure.
2. **Route `simd_dot` work** through PH-7e master-plan partial (`gap-plan-debt-lic-master-plan-phase-7e-*`) — no unproved SIMD shortcuts.
3. **Close registry drift** — auto-close or re-audit `gap-benchmark-red-*` when `ecosystem-audit.red` is empty.
4. **Bake `python3-yaml`** in org-research Job so supervisor ticks do not regress.
5. **Dispatch order:** `ci_maintainer` → `bench_improver` / `numerics_researcher` → `gap_explorer`.

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780638876676.md`

## Deferred publish

Copy to `research-findings` when repo is mounted in the research lane.
