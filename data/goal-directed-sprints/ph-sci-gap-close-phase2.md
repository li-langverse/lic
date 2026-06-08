---
workflow_repo: lic
branch: main
plan: data/goal-directed-sprints/ph-sci-gap-close-phase2.md
parent: data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md
---

# PH-SCI simulation gap-close — Phase 2 kickoff

**Last updated:** 2026-06-06 · **main @** `e87165b7` (Phase 0/1 + echem merged; start from latest `main`)  
**Prerequisite:** `bash scripts/ph-sci-phase0-gates.sh` passes (regression spine).  
**Parent plan:** [ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md) — Phase 2 WPs (11 open).

## Exit criteria (Phase 2)

Phase 2 is complete when the WPs below are landed and documented; no single gate script yet — use package smokes + tier-2 oracle extensions per WP.

## P0 order (start here)

1. **WP-SCI-03** — `run_algo_registry` real kernels (CFD/FEA/QM rows); extend `run_algo_registry_tier2.li`. **Partial:** CFD/FEA/QM tier-2 oracles landed; WP-PLAT-05 external MD oracle still open.
2. **WP-PLAT-05** — LAMMPS/GROMACS external oracle column (unblocks SCI-03 MD rows).
3. **WP-SCI-04** — `sim.viz` → wgpu field draw (depends WP-GD-05 / PH-HW-2).

## P1 queue

| WP | Title | Packages |
|----|-------|----------|
| WP-SIM-04 | Full `SimWorld` replay buffer | `li-sim`, `li-world` |
| WP-SIM-05 | Real sensor raycast | `li-sim-sensors`, `li-scene` |
| WP-GAME-02 | Scene graph ↔ physics sync | `li-scene`, `li-physics-runtime` |
| WP-ROBO-03 | IK analytic / better numeric | `li-sim-robotics` |
| WP-AM-02 | Thermal gate (`require_sim_pass`) | `li-sim-additive` |
| WP-SCI-05 | FEA linear elasticity scaffold | `li-sim-scientific` |
| WP-SCI-06 | CFD lid-driven cavity | `li-physics-fluids` |
| WP-AUTO-02 | Lane map + odometry | `li-sim-automotive` |
| WP-DRUG-04 | Live `chem.dft` queue | `li-sim-drug-design`, `li-chem` |

## Iteration rules

1. Branch off `main`; one WP or logical chunk per PR.
2. Do **not** regress `./li-tests/run_all.sh science_gpu` or `scripts/ph-sci-phase0-gates.sh`.
3. Update the parent plan WP row when a Phase 2 item lands.
4. After Phase 2, hand off to Phase 3 vendor GPU ([WP-SCI-GPU-VENDOR-01](ph-sci-simulation-gap-close-plan.md#wp-sci-gpu-vendor-01--science-kernel-lkir-lowering-pilot)).

## Verification commands

```bash
bash scripts/ph-sci-phase0-gates.sh
./li-tests/run_all.sh science_gpu
./li-tests/run_all.sh smoke  # li-sim-scientific manifests
```

## K8s worker

Deployed via `li-cursor-agents/scripts/setup-engine-k8s-ph-sci-gap-close-phase2.sh` (replicas default 0 — scale when ready).
