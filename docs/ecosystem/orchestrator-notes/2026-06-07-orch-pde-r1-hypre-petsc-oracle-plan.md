# Orchestrator note — pde-r1-hypre-petsc-oracle-plan

**Date:** 2026-06-07  
**Issue:** [lic#108](https://github.com/li-langverse/lic/issues/108)  
**Agent:** `issue_planner` (worker `0606ee21`)  
**Plan:** [2026-06-07-pde-r1-hypre-petsc-oracle-plan.md](../../superpowers/plans/2026-06-07-pde-r1-hypre-petsc-oracle-plan.md)

## north_star_fit

Scientific computing / HPC implicit PDE — **PH-5b**, **PH-7e**, **PH-7d**; **G-math**, **G-physics**, **G-gpu** (watch). Proof-first: external PETSc+hypre validity column before perf or GPU PCBJKOKKOS.

## Swarm gap mapping

| Gap ID | Plan WP |
|--------|---------|
| `gap-hpc-hypre-boomeramg-tier2-pde` | wp-pde-stack-spec, wp-pde-driver-stub |
| `gap-hpc-petsc-kokkos-implicit-pde` | wp-pde-stack-spec (T2b deferred) |
| `gap-vertical-stub-pde-heat-2d` | wp-pde-registry-honesty |

## Handoff queue

| After plan-approved | Agent | Branch |
|---------------------|-------|--------|
| wp-pde-stack-spec → wp-pde-study | `numerics_researcher` | `cursor/sim-pde-research-loop` |
| Optional CI profile | `bench_improver` | harness only — no cron |

## Not duplicate of

- lic#28 (PETSc–Kokkos execution patterns — closed; T2b cross-link only)
- lic#33 (Eigen numerics pin — shared bench policy, separate issue)
- md-r3-oracle-plan (MD LAMMPS/GROMACS — different vertical)
