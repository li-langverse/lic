---
workflow_repo: lic
branch: main
plan: data/goal-directed-sprints/ph-sci-gap-close-phase2.md
parent: data/goal-directed-sprints/ph-sci-simulation-gap-close-plan.md
---

# PH-SCI simulation gap-close — Phase 2 kickoff

**Last updated:** 2026-06-10 · **main @** `bd681dd71` (agent re-verify `code_implementer-1781079259353`)  
**Prerequisite:** `bash scripts/ph-sci-phase0-gates.sh` passes (regression spine).  
**Parent plan:** [ph-sci-simulation-gap-close-plan.md](ph-sci-simulation-gap-close-plan.md) — Phase 2 **complete** (gate: `scripts/ph-sci-gap-close-phase2-gate.sh`).

## Exit criteria (Phase 2)

Phase 2 is complete when the WPs below are landed and documented; gate: `bash scripts/ph-sci-gap-close-phase2-gate.sh`.

| WP | Status |
|----|--------|
| WP-SCI-03 | **done** — CFD/FEA/QM tier-2 registry dispatch |
| WP-PLAT-05 | **done** — `md_oracle.toml` + `run-md-oracle-external.sh` |
| WP-SCI-04 | **done** — `viz_wgpu_field_draw_step` progression smoke |
| WP-SIM-04 | **done** — entity snapshot replay on session |
| WP-SIM-05 | **done** — scene bounds raycast |
| WP-GAME-02 | **done** — scene ↔ physics pose sync APIs |
| WP-ROBO-03 | **done** — 2-link analytic IK reference |
| WP-AM-02 | **done** — heat oracle thermal gate |
| WP-SCI-05 | **done** — FEA linear elasticity oracle |
| WP-SCI-06 | **done** — CFD lid cavity checksum |
| WP-AUTO-02 | **done** — map tile + odom checksum |
| WP-DRUG-04 | **done** — chem.dft job queue roundtrip |

## P0 order (completed)

1. **WP-SCI-03** — `run_algo_registry` real kernels (CFD/FEA/QM rows); extend `run_algo_registry_tier2.li`.
2. **WP-PLAT-05** — LAMMPS/GROMACS external oracle column (unblocks SCI-03 MD rows).
3. **WP-SCI-04** — `sim.viz` → wgpu field draw (depends WP-GD-05 / PH-HW-2).

## Verification commands

```bash
bash scripts/ph-sci-gap-close-phase2-gate.sh
bash scripts/ph-sci-phase0-gates.sh
./li-tests/run_all.sh science_gpu
bash scripts/ph-sci-gpu-gates.sh
```

## K8s worker

Scale `li-ph-sci-gap-close-phase2` to 0 after gate passes (`LI_PROOF_EXPLORER_EXIT_ON_COMPLETE=1`).
