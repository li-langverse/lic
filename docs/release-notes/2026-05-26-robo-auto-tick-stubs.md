# Release notes: 2026-05-26 — robo-auto-tick-stubs

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-ROBO ROBO-0, PH-SIM (automotive workspace)  
**Author:** agent

---

## Summary (one sentence)

Wires `li-sim-automotive` and `li-sim-robotics` domain tick stubs into `studio_sim_step_hook` with proof-gated composables and package smokes.

## Agent continuation (required)

1. Read: `packages/li-studio/src/lib.li` (`studio_sim_step_hook`), `packages/li-sim-robotics/src/lib.li`, `packages/li-sim-automotive/src/lib.li`.
2. Run: `lic check packages/li-sim-robotics/li-tests/smoke/tick_stub.li`; `lic check packages/li-sim-automotive/li-tests/smoke/tick_stub.li`; `lic check li-tests/composable/import_sim_robotics_workspace.li`; `./scripts/check-robotics-bench.sh`.
3. Then: IK / lane maps / sensor raycast — not this PR.
4. Blocked on: none.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-sim` | `vertical_sim_*`, `algo_auto_*` constants | registry ids 901–903 |
| `li-sim-robotics` | `sim_robotics_tick_stub`, `run_robo_multibody_smoke` | tick smoke + composable |
| `li-sim-automotive` | `sim_automotive_tick_stub`, `run_auto_bicycle_smoke` | tick smoke + composable |
| `li-studio` | `studio_sim_step_hook` automotive + robotics branches | `studio_sim_step_by_profile.li` |
| Composables | `import_sim_robotics_workspace`, `import_sim_automotive_workspace` | bench scripts |

## Not changed (scope fence)

- CARLA/AirSim parity, ROS2 bridge, full IK — PH-ROBO ROBO-1+.
- Native demo MP4 content — unchanged honest placeholders.

## Breaking changes

None.
