# Orchestrator note — `competitor-gaps` (`ed666cf5`)

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage`  
**Dimension:** `competitor-gaps`  
**north_star_fit:** ecosystem, ai — PH-5b (numerics/PDE), PH-7e (SIMD/parallel), PH-7d (execution decorators)

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D (65.8)**, `unattended_safe: false` |
| Open `competitor_feature` gaps | **30** (unchanged since 2026-05-31 ingest) |
| Benchmark audit (live) | **0 red**, 2 yellow, 5 near-threshold vs cpp |
| Gap ingest | **Blocked** → SyntaxError **fixed** locally; apply still blocked on PyYAML |
| Unattended? | **No** — PyYAML + control-plane bootstrap + CI debt |

---

## Competitor gap taxonomy (open rows)

### A. Legacy tier-1 red registry rows (reconcile on ingest)

These predate the current audit (0 red). Keep rows until `bench_improver` closes harness gaps or ingest marks them `closed`:

| Registry id | Competitor class | Handoff |
|-------------|------------------|---------|
| `gap-benchmark-red-matmul-naive-tier1` | Eigen/MKL matmul | `bench_improver`, `numerics_researcher` |
| `gap-benchmark-red-num-gmres-tier1` | iterative KSP | `numerics_researcher` |
| `gap-benchmark-red-num-integ-euler-tier1` | explicit integrator | `numerics_researcher`, `bench_improver` |
| `gap-benchmark-red-num-integ-verlet-tier1` | symplectic | `numerics_researcher` |
| `gap-benchmark-red-num-opt-line-search-tier1` | optimization | `numerics_researcher`, `bench_improver` |
| `gap-benchmark-red-cloth-swing-tier1` | tier-2 physics | `numerics_researcher` |
| `gap-benchmark-red-orbit-two-body-tier1` | N-body | `numerics_researcher` |
| `gap-benchmark-red-schrodinger-1d-barrier-tier1` | quantum PDE | `numerics_researcher` |

**Live near-threshold (briefing):** `num_opt_bfgs`, `num_integ_*`, `num_cg` — enqueue `bench_improver` via `numerics_sota` goal; cite PH-7e before SIMD work.

### B. HPC library parity (7 rows)

| Registry id | Incumbent | Swarm goal |
|-------------|-----------|------------|
| `gap-hpc-kokkos-execution-memory-spaces` | Kokkos Views/GPU spaces | `scientific_distributed_computing` |
| `gap-hpc-petsc-kokkos-implicit-pde` | PETSc 3.25 Kokkos KSP/PC | `numerics_sota` |
| `gap-hpc-fftw-roofline-catalog-row` | FFTW / cuFFT roofline | `numerics_sota` |
| `gap-hpc-hypre-boomeramg-tier2-pde` | hypre BoomerAMG | `physics_sim` |
| `gap-hpc-raja-execution-policies` | RAJA vs Li decorators | `numerics_sota` (PH-7d) |
| `gap-hpc-sundials-stiff-ode-sensitivity` | SUNDIALS stiff ODE | `numerics_sota` |
| `gap-hpc-openmp-llvm-lowering-rubric` | OpenMP lowering rubric | `numerics_sota` (PH-7e) |

Handoff chain: `numerics_researcher` → whitepaper → `issue_planner` for lic issues (no product code in this note).

### C. Vertical stubs (12 rows) — patched to sim-md-research backlog

Prior apply (`swarm-gap-actions.json` 2026-05-31) patched 9 stubs → `docs/ecosystem/sim-md-research-backlog.md`. Remaining without backlog patch:

| Registry id | Vertical | Suggested goal |
|-------------|----------|----------------|
| `gap-vertical-stub-pde-heat-2d` | OpenFOAM/PETSc | `physics_sim` |
| `gap-vertical-stub-fea_linear_elasticity` | CalculiX | `engineering_mechanical` |
| `gap-vertical-stub-cfd-lid-driven-cavity` | OpenFOAM | `physics_sim` |

Route MD/QM/cinematic stubs via `md_sim_algorithms` / `chem_sim_algorithms` — already in backlog from prior apply.

### D. Infra + catalog

| Registry id | Action |
|-------------|--------|
| `gap-infra-verticals-toml-missing-benchmarks-main` | Merge `benchmarks/competitive/verticals.toml` PR; then re-run ingest |
| `gap-competitor-pure-li-ph7e-catalog` | `bench_improver` + pure_li catalog expansion |
| `gap-competitor-chapel-hpsf-productivity` | `gap_explorer` research → `issue_planner` (PH-7d) |

---

## Scripts

```bash
# Fixed SyntaxError at line 229 before this note
python3 scripts/swarm-gap-ingest.py          # requires PyYAML for _load_yaml in apply only; ingest uses stdlib + yaml in registry load
python3 scripts/swarm-gap-apply-actions.py   # BLOCKED: PyYAML required
```

**Do not** recommend `install-goal-plan-loop-systemd.sh` — competitor work routes through async swarm goals per `docs/ecosystem/swarm-architecture.md`.

---

## Handoffs (cite north_star_fit)

| To | Work |
|----|------|
| `gap_explorer` | Re-ingest after PyYAML; close infra row when verticals.toml on benchmarks main |
| `numerics_researcher` | `numerics_sota`, `md_sim_algorithms`, `physics_sim` — competitor bench + HPC surveys |
| `bench_improver` | Near-threshold integrators/opt; legacy tier-1 red closure |
| `issue_planner` | Package/HPC issues from whitepapers — not direct registry edits |
| `plan_verifier` | Refresh snapshot; dedupe plan_debt rows |

---

## Evidence

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json` (benchmarks.yellow, near_threshold)
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- Observer run: `/app/data/runs/swarm_observer-1780948518302.md`
