# Swarm gap orchestration — competitor-gaps dimension

**Goal:** `swarm_coverage`  
**Dimension:** `competitor-gaps`  
**Worker:** `5e52da5c`  
**Date:** 2026-06-08  
**north_star_fit:** ecosystem, ai — competitor parity and honesty before perf shortcuts (PH-5b, PH-7d, PH-7e)  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/competitor-gaps/`

---

## Abstract

This pass audits whether the Li agent swarm correctly discovers, registers, and routes **competitor_feature** gaps — HPC library parity, vertical benchmark stubs, and tier-1 bench regressions — through the async research lane and gap apply pipeline. The swarm is **degraded** (grade D); competitor gap **orchestration is queued but not refreshing** because PyYAML-dependent ingest is blocked and `verticals.toml` is absent on benchmarks main.

---

## 1. Registry posture

**Source:** `/workspace/lic/data/swarm-gap-registry/registry.yaml` + `/workspace/benchmarks/data/latest/swarm-gap-actions.json`

| `gap_kind` | Open | Closed (sample) |
|------------|-----:|-----------------|
| `competitor_feature` | **30** | — |
| `plan_debt` | 31 | httpd/studio-ui completed rows |
| `missing_package` | 3 (1 active: line_profiler) | std.io, std.csv, std.summary, std.plot |

**Competitor_feature breakdown:**

1. **Vertical honesty (12 stubs)** — `verticals.toml` workloads marked `workload_class = "stub"` vs LAMMPS, OpenFOAM, VASP, etc.
2. **HPC library catalog (8)** — Kokkos, PETSc, hypre, FFTW, RAJA, SUNDIALS, OpenMP, Chapel vs Li std/execution.
3. **Historical tier-1 red benches (9)** — matmul, GMRES, integrators, physics tier-2 rows in registry.
4. **Infra (1)** — `gap-infra-verticals-toml-missing-benchmarks-main`.

---

## 2. Live audit vs registry drift

**Source:** `/workspace/benchmarks/data/latest/ecosystem-audit.json` (2026-06-08)

| Audit class | Count | Notes |
|-------------|------:|-------|
| Red (tier-1) | **0** | Registry still lists 9 `gap-benchmark-red-*` rows |
| Yellow | **2** | `num_eig_symmetric`, `num_root_newton` |
| Near-threshold | **5** | integrators/optimizers ~1.18–1.20× vs cpp |
| Green | **145** | — |

**Implication:** Orchestrator should **close or downgrade** registry red rows when audit confirms sustained green, to avoid stale P8 dispatch to `bench_improver`. Yellow rows remain valid competitor signals for `numerics_researcher`.

---

## 3. Apply pipeline status

Last successful apply: **2026-05-31** (`swarm-gap-actions.json`).

**Patches applied (competitor subset):**

- 9 vertical stubs → `sim-md-research-backlog.md` (md_lennard_jones, drug_litl, bio_litl, scientific_viz, cinematic_*, mmo_shard, qm_dft)
- 4 physics/CAE stubs (`pde_heat_2d`, `fea_linear_elasticity`, `cfd_lid_driven_cavity`) — **no patch** in actions JSON

**This cycle (2026-06-08):** ingest + apply **failed**:

```
swarm-gap-ingest: PyYAML required (pip install pyyaml)
swarm-gap-apply-actions: PyYAML required
```

Container lacks `python3-yaml` and `pip`. Image fix required for unattended gap orchestration.

---

## 4. Infra blockers

| Blocker | Impact | Resolution |
|---------|--------|------------|
| PyYAML missing | No registry refresh or backlog patches | Add to `li-cursor-agents` observer image |
| lic#1504 CI fail | Ingest Path fallback not on main | Fix CI, merge |
| `verticals.toml` not on benchmarks main | `ingest_verticals_stubs` returns 0 | PR to benchmarks; link `gap-infra-verticals-toml-missing-benchmarks-main` |
| GitHub rate limit | org_ci_audit preflight fail | Backoff/cache in `ensure-org-repo-ci.py` |

---

## 5. Swarm routing (control plane)

Per `docs/ecosystem/swarm-architecture.md` — **no new lic systemd plan loops**:

| Competitor area | Research goal | Agent |
|-----------------|---------------|-------|
| MD/QM vertical stubs | `md_sim_algorithms`, `chem_sim_algorithms` | `numerics_researcher` |
| PDE/CFD/FEA stubs | `physics_sim`, `simulation_techniques` | `numerics_researcher` |
| HPC execution (Kokkos/RAJA/OpenMP) | `scientific_distributed_computing` | `numerics_researcher` |
| Tier-1 bench gaps | `numerics_sota` | `bench_improver`, `autoresearch` |
| Org-wide explorer signals | `ecosystem_gaps` | `gap_explorer` |
| Meta orchestration | `swarm_coverage` | `swarm_observer` |

Handoffs must cite `north_star_fit` (domain + PH ids). Proof-before-perf: no unproved shortcuts for competitor bench velocity.

---

## 6. Recommendations

1. **Unblock ingest** — PyYAML in CI/observer image; merge lic#1504 when green.
2. **Ship `verticals.toml`** on benchmarks main; close infra gap row.
3. **Reconcile registry red rows** with live audit (0 red) — close stale `gap-benchmark-red-*` or document regression re-test cadence.
4. **Dispatch `gap_explorer`** after ingest refresh to pick up new vertical/catalog signals.
5. **Route HPC competitor gaps** to `numerics_researcher` session goals, not product code in lic meta pass.
6. **Fix grader `runs_dir`** fallback so swarm_execution dimension scores in observer container.
7. **Do not** disable provability gates or Lean policy for competitor parity work.

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/ecosystem-audit.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/app/data/runs/swarm_observer-1780962195694.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-08-orch-competitor-gaps-5e52da5c.md`
