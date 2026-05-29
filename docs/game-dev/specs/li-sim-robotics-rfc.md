# RFC: li-sim-robotics

**Status:** Draft (v1 landed in lic monorepo)  
**Date:** 2026-05  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

World Studio **sim_robotics** (profile id 4) needs a proof-first vertical slice for arms and planners before ROS2/MuJoCo-class integrations. Tier-2 benches (`robo_*` in `benchmarks/competitive/algo_registry.json`) already register ids 801–805; package code must expose deterministic smokes composable from `import sim.robotics`.

## Proposal (v1 — shipped)

| Work package | API | Bench id | Notes |
|--------------|-----|----------|-------|
| WP-ROBO-01 | `sim_robotics_tick_*` | — | Studio tick + workspace gate |
| WP-ROBO-02 | `robo_arm_fk`, `sim_robotics_workspace_bounds_ok` | — | 2-DOF FK (small-angle stub) |
| WP-ROBO-03 | `sim_robotics_joint_angles_tick`, `run_robo_ik_jacobian_smoke` | 802 | Numeric IK stub; full Jacobian later |
| WP-ROBO-04 | `robo_plan_rrt_checksum_*`, `run_robo_plan_rrt_smoke` | 803 | 64-node deterministic RRT smoke; tier-2 harness uses C oracle at 12k nodes |

Composable gate: `li-tests/composable/import_sim_robotics_run.li`.

## Li syntax

Use **`def`** for all new APIs. **`extern proc`** only for FFI (ROS2, hardware). Every exported `def` needs `requires` / `ensures` / `decreases`.

## Proof / trust

- Package smokes are `lic check` / composable `compile_open_ok`.
- Tier-2 competitive benches remain C-oracle + `LI_EXTRA_C` until pure-Li planners prove parity.

## Dependencies

- `li-sim` contracts (`sim_contract_sim_robotics`, `algo_robo_*`).
- See [PH-world-studio-program.md](../PH-world-studio-program.md).

## Open questions / deferred (researcher agent)

- [ ] **ROS2 bridge** (`WP-ROBO-05`) — joint state `extern`, audit log; needs dedicated **robotics researcher** (hardware I/O policy).
- [ ] **6-DOF IK + workspace** — blocked on math quat / full trig in prelude.
- [ ] **Factory multi-arm layout** (`WP-ROBO-04` scene) — after IK numeric path.
- [ ] Catalog `path` rows for `robo_*` in **benchmarks** repo — track with `bench_improver`, not product code here.
