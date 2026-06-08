# Swarm gap orchestration — performance lens

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Worker:** `6e2efb9a`  
**Date:** 2026-06-08  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/performance/`

---

## Abstract

Meta-audit of Li swarm health through a **performance** lens: numerics bench posture, performance-class gap registry rows, and control-plane blockers that prevent automated gap-to-backlog routing. The swarm cannot close PH-7e / PH-5b performance debt unattended while gap ingest remains syntactically broken and PyYAML is absent from the runner image.

---

## Bench posture (proof-before-perf)

Pillar order requires proved numerics before SIMD/parallel shortcuts. Current tier-1 audit (`ecosystem-audit.json`, 2026-06-01):

- **Red:** 0 (improved since May scorecard cited red rows)
- **Yellow:** `num_eig_symmetric`, `num_root_newton`
- **Near threshold (1.18–1.20× C++):** BFGS, Euler/RK4/semi-implicit integrators, CG

These align with open registry rows `gap-benchmark-red-*` and master-plan partial **Phase 7e** (SIMD matmul deferred). Closing yellow rows is the highest-leverage unattended path once `bench_improver` + `numerics_researcher` receive handoffs from refreshed gap apply.

---

## Gap registry — performance taxonomy

| `gap_kind` | Performance examples | Swarm route |
|------------|---------------------|-------------|
| `competitor_feature` | matmul_naive, GMRES, Kokkos, FFTW roofline | `numerics_researcher`, `bench_improver` |
| `plan_debt` | Phase 7e SIMD, 8p parallel compile, sim dot/axpy | `plan_verifier` → implement goals |
| `missing_package` | `li-line-profiler` (HPC profiling) | `issue_planner` |

**Blocked automation:** `swarm-gap-actions.json` last generated 2026-05-31; ingest cannot refresh until `swarm-gap-ingest.py:229` is fixed.

---

## Control-plane performance findings

1. **`LI_CURSOR_AGENTS_ROOT` mismatch** — default grader path `/workspace/li-cursor-agents` vs runtime `/app` caused `runs_sampled=0` until env override; recommend default `/app` in `ecosystem-quality-grade.py` or container env.
2. **Goal-directed snapshot stale** (2026-05-30) — 6 runners stopped; perf todos (httpd wrk soak, sim dot/axpy) not advancing.
3. **Prior SDK failure** — `swarm_coverage@security` run 2026-06-08T07:34Z ended `tools=0` after 34s (premature SDK error); programmatic retry budget unused.

---

## Recommendations

1. Merge lic PR fixing gap-ingest syntax; bake PyYAML in org-research Job image.
2. Set `LI_CURSOR_AGENTS_ROOT=/app` in supervisor and grader preflight.
3. Dispatch: `pr_merger` (lip#52) → `ci_maintainer` → `bench_improver` + `numerics_researcher` → `gap_explorer`.
4. Human-gated: lic#11 pure-Li horner / PH-7e codegen — no auto-merge.

---

## References

- `docs/ecosystem/research-verticals.md` — `swarm_coverage` goal, numerics verticals
- `docs/ecosystem/orchestrator-notes/2026-06-08-orch-r15-performance-gaps.md`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
