# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **WP-ROBO-04** — deterministic `robo_plan_rrt_checksum_smoke` + `run_robo_plan_rrt_smoke` (registry **803**); `run_robo_ik_jacobian_smoke` (**802**); `run_robo_algo` dispatcher; composable `li-tests/composable/import_sim_robotics_run.li`; smoke `li-tests/smoke/plan_rrt.li`.
- **WP-ROBO-02/03** — 2-DOF FK (`robo_arm_fk`), workspace gate (`sim_robotics_workspace_bounds_ok`), numeric IK stub tick (`sim_robotics_joint_angles_tick`), ROBO-0 tick helpers (`sim_robotics_tick_at` / `sim_robotics_tick_stub`), smoke `li-tests/smoke/workspace_bounds.li`.

### Changed

- `li_sim_robotics_version()` **2 → 3**; `run_robotics_smoke()` covers plan RRT + IK jacobian smokes.
- `li-sim`: `algo_robo_ik_jacobian()` / `algo_robo_plan_rrt()` constants (**802**, **803**).

### Changed

- `li_sim_robotics_version()` **1 → 2**; `run_robotics_smoke()` exercises FK, workspace, and joint-angle tick paths.

### Added (prior)

- PH-SIM vertical gap **#3** — profile contract + studio id constants, `run_robotics_smoke()`, package smoke (`li-tests/smoke/builds.li`).

## [0.1.0] - 2026-05-26

### Added

- Package skeleton (`sim.robotics`).
