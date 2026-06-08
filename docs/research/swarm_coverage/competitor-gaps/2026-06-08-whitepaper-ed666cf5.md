# Swarm coverage — competitor gaps lens

**Goal id:** `swarm_coverage`  
**Dimension:** `competitor-gaps`  
**Worker:** `ed666cf5`  
**Date:** 2026-06-08  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/competitor-gaps/`  
**north_star_fit:** ecosystem, ai — proof → easy → fast; PH-5b, PH-7e, PH-7d

---

## Abstract

Li’s agent swarm tracks **64 open capability gaps** in a central registry; **30 are `competitor_feature`** rows comparing Li to incumbent HPC, numerics, and vertical simulation stacks. This pass audits registry health, live benchmark posture, and orchestration blockers for the competitor-gaps research dimension under the `swarm_coverage` meta goal.

---

## Live benchmark posture (2026-06-08 briefing)

| Class | Count | Examples |
|-------|------:|----------|
| Tier-1 red | 0 | — (improved vs May registry) |
| Yellow | 2 | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold (1.18–1.20× cpp) | 5 | BFGS, Euler/RK4/semi-implicit integrators, CG |
| Green | 145 | — |

**Interpretation:** Performance debt shifted from “red” to “near-threshold” for core integrators/optimizers. Registry tier-1 red rows are **stale labels** until `swarm-gap-ingest.py` reconciles against fresh `ecosystem-audit.json`.

---

## Competitor gap inventory (30 open)

### Numerics / tier-1 (8 legacy red + 1 catalog)

Li lags C++/Eigen/MKL-class microbenches on matmul, GMRES, integrators, line search, and selected tier-2 physics oracles. Remediation path: proved SIMD lowering (PH-7e) after contract coverage (PH-2e/2f) — no unproved `unsafe` shortcuts.

### HPC runtime libraries (7)

Kokkos execution spaces, PETSc Kokkos KSP/PC, FFTW roofline, hypre AMG, RAJA policies, SUNDIALS stiff ODE, OpenMP lowering rubric. Li’s partial coverage lives in `std/execution` decorators (PH-7d) and tier-2 numerics — research handoff via `scientific_distributed_computing` and `numerics_sota` goals.

### Vertical honesty stubs (12)

`verticals.toml` marks MD, PDE, FEA, CFD, QM, cinematic, and MMO workloads as **stub** vs LAMMPS, OpenFOAM, VASP, FFmpeg, etc. Nine stubs were patched into `sim-md-research-backlog.md` (2026-05-31 apply). Remaining PDE/FEA/CFD stubs should bind to `physics_sim` and `engineering_mechanical` goals.

### Infra (2)

- `verticals.toml` missing on **benchmarks** main blocks automated vertical ingest.
- Chapel 2.x / HPSF productivity comparison vs Li PH-7d execution model.

---

## Orchestration findings

1. **`swarm-gap-ingest.py` SyntaxError (line 229)** — fixed 2026-06-08; previously blocked all vertical stub refresh.
2. **`swarm-gap-apply-actions.py`** requires PyYAML — not present in org-research worker image; backlog patches frozen since 2026-05-31.
3. **Control-plane** missing `state.json` / `latest-report.json` — programmatic observer cannot auto-retry or surface `swarm_degraded` accurately.
4. **Grader** samples 0 runs — set `LI_CURSOR_AGENTS_ROOT=/app` so `ecosystem-quality-grade.py` reads local run history.

---

## Recommended research sequence

1. **`gap_explorer`** — re-ingest registry after PyYAML; close stale tier-1 rows against live audit.
2. **`numerics_researcher`** — `numerics_sota`: near-threshold integrator/opt whitepaper with PH-7e proof obligations.
3. **`bench_improver`** — harness fixes for yellow eigen/root finders; SIMD candidates from whitepaper.
4. **`issue_planner`** — file lic/benchmarks issues from published findings; no direct registry product edits.

---

## References

- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- Orchestrator note: `docs/ecosystem/orchestrator-notes/2026-06-08-orch-competitor-gaps-ed666cf5.md`
- Vision: `docs/ecosystem/vision-and-roadmap.md` (proof → easy → fast)
