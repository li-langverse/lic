# Wave D — robotics vertical `robo_workspace` (2026-05-23)

## Summary

**wave-d-23-vertical-robo:** `li-sim-robotics` workspace composable, `robotics.toml` bench row, PH-ROBO RFC cross-links, and `verticals.toml` honesty.

## Changes

- `packages/li-sim-robotics/` — scaffold via `li-new-package`; `import_name = "sim.robotics"`; `workload_class=stub`
- `packages/li-sim-robotics/src/lib.li` — `sim_robotics` profile + PH-ROBO phase tick stub
- `li-tests/composable/import_sim_robotics_workspace.li` — workspace composable
- `benchmarks/competitive/robotics.toml` — `robo_workspace` composable bench row
- `benchmarks/competitive/verticals.toml` — new `robo_workspace` row
- `scripts/check-robotics-bench.sh` — gate (wired in `hpc_competitive_registry.sh`)
- `docs/game-dev/specs/li-sim-robotics-rfc.md` — PH-ROBO cross-links
- `docs/ecosystem/vertical-algorithm-catalog.md` — robo_workspace section

## Plan

Marks `wave-d-23-vertical-robo` on compiler-studio plan loop.
