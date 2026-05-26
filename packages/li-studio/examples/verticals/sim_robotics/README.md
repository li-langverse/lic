# Studio vertical: `sim_robotics`

**Focus:** Profile chip + inspector joint fields + `studio_sim_step_hook` 2-DOF arm FK/torque tick (`sim.robotics`).

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
lic check packages/li-sim-robotics/li-tests/smoke/tick_stub.li
lic check li-tests/composable/import_sim_robotics_workspace.li
./scripts/check-robotics-bench.sh
```

## Honest status

IK, factory cells, and ROS2 bridge are **not** implemented — one `physics.rigid` integrator step per tick (algo **801**) only.

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_robotics.html`
