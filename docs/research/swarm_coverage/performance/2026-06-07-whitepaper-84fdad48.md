# Swarm coverage — performance dimension

**Goal:** `swarm_coverage`  
**Dimension:** `performance`  
**Agent:** `swarm_observer`  
**Worker:** `84fdad48`  
**Run:** `swarm_observer-1780822114208`  
**Generated:** 2026-06-07T09:16Z  
**north_star_fit:** ecosystem, ai — proof → easy → fast (PH-7e, PH-5b)

> Staging copy for `research-findings/whitepapers/2026-06/swarm_coverage/performance/` — publish when repo is mounted.

## Abstract

Meta-audit of Li swarm health through a **performance lens**: benchmark posture, gap-registry performance rows, and orchestration bottlenecks that block unattended numerics improvement. Ecosystem quality scores **69.6 (D)**; gap ingest/apply is blocked on missing PyYAML despite a remediated ingest syntax error.

## Benchmark posture (2026-06-07)

| Tier | Count | Examples |
|------|-------|----------|
| Green | 145 | Majority of tier-1/2 harness |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (1.15–1.20× cpp) | 5 | `num_opt_bfgs`, integrators, `num_cg` |
| Red (dashboard) | 0 | Registry still lists tier-1 red stubs — reconcile after ingest refresh |

**Pillar order respected:** No perf shortcuts recommended without proof gates. Phase 7e SIMD matmul remains deferred (`gap-plan-debt-lic-master-plan-phase-7e-math-simd-parallel-lowe`).

## Gap-registry performance pressure

Open gaps with performance impact (subset of 64 total):

- **plan_debt (7):** Phase 7e, 8p parallel compile, sim-p1 numerics todos
- **competitor_feature (12+):** tier-1 red bench stubs, HPC Kokkos/PETSc/FFTW, vertical stubs
- **missing_package (1):** `li-line-profiler` — blocks line-level HPC profiling for agent loops

Apply pipeline last ran **2026-05-31**; live refresh blocked on PyYAML.

## Orchestration performance findings

1. **`runs_sampled=0` default** — `ecosystem-quality-grade.py` assumes `li-cursor-agents` sibling path; container uses `/app`. Fix: `LI_CURSOR_AGENTS_ROOT=/app` in worker env.
2. **Goal-directed runners** — 6/9 stopped; snapshot 8 days stale → sim/httpd perf gates not advancing.
3. **PR stack duplication** — 6 failing benchmarks PRs for same GPU picker fix; 264 redundant pairs org-wide → merge throughput drag.
4. **Preflight `--skip-slow`** — plan_audit skipped → plan_debt gaps not auto-closed.

## Recommended handoffs

| Target | Work |
|--------|------|
| `bench_improver` | Yellow + near-threshold numerics |
| `numerics_researcher` | PH-7e catalog, HPC competitor gaps |
| `gap_explorer` | Reconcile 30 competitor_feature rows post-PyYAML |
| `issue_planner` | `pkg-line-profiler` package seed |
| `ci_maintainer` | 14 repos missing CI |

## Self-heal actions (this run)

- Regenerated scorecard with correct `runs_dir`
- Fixed `swarm-gap-ingest.py:229` syntax
- Bootstrapped control-plane state/report

## Validity

| Field | Value |
|-------|-------|
| `validity_grade` | B- (live briefing + audit; gap apply stale) |
| `status` | staging |
| `evidence_paths` | See orchestrator note `2026-06-07-orch-r11-performance-gap-handoffs-84fdad48.md` |

## References

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/agent-briefing.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r11-performance-gap-handoffs-84fdad48.md`
