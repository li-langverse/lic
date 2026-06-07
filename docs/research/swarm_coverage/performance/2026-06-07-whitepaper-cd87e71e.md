# Swarm gap orchestration — performance dimension

**Goal:** `swarm_coverage`  
**Worker:** `cd87e71e`  
**Date:** 2026-06-07  
**north_star_fit:** ecosystem, ai — orchestrate performance debt without bypassing proof pillar  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/` (deferred — repo not mounted)

---

## Abstract

This audit examines whether the Li agent swarm can close **performance-related gap registry rows** and **benchmark watch-list items** without human intervention. Finding: the gap apply pipeline is **blocked by infrastructure** (missing PyYAML, ingest syntax error now fixed), while numerics posture is **stable-but-soft** (0 red tier-1, 2 yellow, 5 near-threshold). Unattended performance improvement requires unblocking ingest, dispatching `bench_improver`/`numerics_researcher`, and completing httpd wrk soak plan debt — all routable via existing research goals, not new systemd loops.

---

## 1. Scorecard context

| Metric | Value | Source |
|--------|-------|--------|
| Overall score | 65.8 (D) | `ecosystem-quality-report.json` |
| `unattended_safe` | false | same |
| `gap_pressure` | 60.0 — 64 open gaps | same |
| Benchmark red | 0 | `agent-briefing.json` |
| Benchmark yellow | 2 (`num_eig_symmetric`, `num_root_newton`) | same |
| Near-threshold | 5 rows (1.18–1.20× vs cpp) | same |

Proof-before-perf: yellow rows are **watch**, not emergency bypass of Lean policy.

---

## 2. Gap pipeline as performance bottleneck

The swarm cannot patch sim/httpd/studio-ui backlogs until:

1. **`swarm-gap-ingest.py`** runs — fixed SyntaxError at line 229 (Path + `verticals.toml`).
2. **`PyYAML`** is available — currently `ModuleNotFoundError` in org-research container.

**Cost:** 64 open gaps include ~15 performance-class rows (tier-1 reds, PH-7e plan debt, httpd wrk soak). Stale `swarm-gap-actions.json` (2026-05-31) means handoffs to `bench_improver` are not refreshed.

---

## 3. Performance gap taxonomy (open sample)

### 3.1 Competitor / benchmark gaps

High-priority tier-1 reds in registry (historical audit; briefing now 0 red — drift to reconcile on re-ingest):

- `matmul_naive`, `num_gmres`, `num_opt_line_search` — handoff `bench_improver` + `numerics_researcher`, PH-7e/PH-5b

### 3.2 Plan debt — execution surface

- **Phase 7e** SIMD matmul deferred — master plan partial; route `plan_verifier` → `issue_planner`
- **Phase 8p** parallel compile / CI throughput — aligns with 14 repos missing CI
- **httpd** `gap-phase2-perf-wrk-soak` — pending in snapshot; nginx wrk soak gate

### 3.3 Sim / UI latency

- `sim-p1-num-dot-axpy` — BLAS microbench backlog (apply patch exists)
- `studio-ux-16-palette-search-latency` — UI perf; handoff `gui_ux_tester`

---

## 4. Near-threshold watch list

Integrators and optimizers at 1.18–1.20× vs cpp are **pre-red** signals:

| id | ratio |
|----|-------|
| num_opt_bfgs | 1.1978 |
| num_integ_semi_implicit | 1.19 |
| num_integ_euler | 1.1863 |
| num_integ_rk4 | 1.1863 |
| num_cg | 1.1848 |

**Recommendation:** Add briefing signal for `bench_improver` when ≥3 near-threshold rows share a harness family (integrators vs optimizers).

---

## 5. Swarm execution blind spot

`ecosystem-quality-grade.py` sampled **0 runs** because default `runs_dir` (`/workspace/li-cursor-agents/data/runs`) is empty; actual runs live at `/app/data/runs`. This under-scores `swarm_execution` and hides error streaks from programmatic observer.

**Fix:** Set `LI_CURSOR_AGENTS_ROOT=/app` in org-research worker env.

---

## 6. Recommendations

1. **P0 infra:** Bake `python3-yaml`; merge ingest syntax fix on `lic`.
2. **P0 dispatch:** `pr_merger` (lip#52) → `ci_maintainer` → `bench_improver`.
3. **P1 research:** `numerics_researcher` on PH-7e gaps via `numerics_sota` goal — no new loops.
4. **P1 httpd:** Complete wrk soak todo via existing httpd research handoff.
5. **P2 control plane:** Persist observer state each tick; fix `runs_dir` default.

---

## 7. Conclusion

Performance improvement in the Li swarm is **orchestration-limited**, not model-limited: gaps are catalogued, backlogs exist, but apply pipeline and leaf-agent dispatch are starved. Unattended operation is **unsafe** until PyYAML, ingest, and briefing-aligned dispatch (`pr_merger`, `ci_maintainer`, `bench_improver`) run on schedule.

---

## References

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r10-performance-cd87e71e.md`
- `data/runs/swarm_observer-1780845525412.md`
