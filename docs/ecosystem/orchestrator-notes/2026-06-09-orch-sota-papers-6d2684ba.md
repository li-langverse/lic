# Orchestrator note — `swarm_coverage@sota-papers` (worker `6d2684ba`)

**Date:** 2026-06-09T02:42Z  
**Run:** `swarm_observer-1780970665278`  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai

## Summary

SOTA-papers dimension audit for gap orchestration. Unblocked ingest/apply pipeline (syntax fix, env default, PyYAML). Registry holds 30 `competitor_feature` rows with explicit literature/HPC library citations — these are the paper-backed backlog for `numerics_researcher`, not product implementation in this pass.

## Ingest / apply evidence

| Step | Path | Result |
|------|------|--------|
| Ingest | `lic/scripts/swarm-gap-ingest.py` | 92 registry rows; `verticals_stubs: 0` |
| Apply | `lic/scripts/swarm-gap-apply-actions.py` | 62 open; 23 patches |
| Registry | `lic/data/swarm-gap-registry/registry.yaml` | authoritative |
| Actions | `benchmarks/data/latest/swarm-gap-actions.json` | generated @ 02:42Z |

## SOTA citation reconciliation (open competitor_feature sample)

| gap_id | Cited SOTA / library | handoff_to |
|--------|----------------------|------------|
| `gap-hpc-kokkos-execution-memory-spaces` | Kokkos parallel_for/Views | `numerics_researcher`, `issue_planner` |
| `gap-hpc-petsc-kokkos-implicit-pde` | PETSc 3.25 Kokkos KSP/PC | `numerics_researcher` |
| `gap-hpc-fftw-roofline-catalog-row` | FFTW vs GPU roofline ([arxiv 2506.08653](https://arxiv.org/html/2506.08653v1)) | `bench_improver`, `gap_explorer` |
| `gap-hpc-raja-execution-policies` | RAJA policies ([arxiv 2402.08950](https://arxiv.org/html/2402.08950v1)) | `numerics_researcher` |
| `gap-hpc-openmp-llvm-lowering-rubric` | OpenMP prescriptive vs descriptive ([OSTI 2224192](https://www.osti.gov/servlets/purl/2224192)) | `numerics_researcher` |
| `gap-competitor-chapel-hpsf-productivity` | Chapel 2.x / HPSF | `gap_explorer`, `issue_planner` |
| `gap-vertical-stub-qm-dft` | QM DFT vertical stub | `numerics_researcher` → sim-chem backlog |

**Blocker:** `gap-infra-verticals-toml-missing-benchmarks-main` — ingest cannot add stub rows until `benchmarks/competitive/verticals.toml` is on main.

## Plan debt (orchestrator-owned)

| todo_id | runner | status | note |
|---------|--------|--------|------|
| `orch-r3-missing-package-sweep` | swarm-observer | open | 1 pkg gap remains (`li-line-profiler`); std.summary/plot closed |
| `orch-r4-ui-ux-signals` | swarm-observer | open | studio-ux patches skipped — backlog path missing in container |
| `chem-r0-sota-survey` | sim-chem-research | **closed** | SOTA survey complete per snapshot |

## Routing (no new agent ids, no systemd loops)

1. `gap_explorer` — after `verticals.toml` merge; refresh competitor rows
2. `numerics_researcher` — HPC/SOTA competitor gaps (PH-5b, PH-7e)
3. `plan_verifier` — plan_debt snapshot sync
4. `issue_planner` — `pkg-line-profiler`
5. `pr_merger` — lip#52 (orthogonal but P0 heap)

## Control-plane fixes applied (local)

- `lic/scripts/swarm-gap-ingest.py` — syntax + `BENCHMARKS_COMPETITIVE` default
- `benchmarks/scripts/ecosystem-quality-grade.py` — `/app/data/runs` fallback

Recommend image bake for PyYAML so apt is not required each pass.
