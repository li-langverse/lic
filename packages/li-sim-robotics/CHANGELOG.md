# Changelog

All notable changes to this package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **WP-ROBO-03 6-DOF numeric IK** — `RoboArm6DofState`, `robo_arm_6dof_ik_numeric_step`, `sim_robotics_session_ik_step`, session persistence via `env_last_obs0..5`; smoke `li-tests/smoke/robo_ik_6dof.li`.
- **WP-ROBO-02/03** — 2-DOF FK (`robo_arm_fk`), workspace gate (`sim_robotics_workspace_bounds_ok`), numeric IK stub tick (`sim_robotics_joint_angles_tick`), ROBO-0 tick helpers (`sim_robotics_tick_at` / `sim_robotics_tick_stub`), smoke `li-tests/smoke/workspace_bounds.li`.

### Changed

- `li_sim_robotics_version()` **1 → 2**; `run_robotics_smoke()` exercises FK, workspace, and joint-angle tick paths.

### Added (prior)

- PH-SIM vertical gap **#3** — profile contract + studio id constants, `run_robotics_smoke()`, package smoke (`li-tests/smoke/builds.li`).

## [0.1.0] - 2026-05-26

### Added

- Package skeleton (`sim.robotics`).
