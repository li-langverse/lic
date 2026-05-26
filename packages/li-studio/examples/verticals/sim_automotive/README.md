# Studio vertical: `sim_automotive`

**Focus:** Profile chip + `studio_sim_step_hook` bicycle kinematics (`x,y,yaw,v`) and sensor placeholder spec (`sim.automotive`).

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
lic check packages/li-sim-automotive/li-tests/smoke/tick_stub.li
lic check li-tests/composable/import_sim_automotive_workspace.li
```

## Honest status

Maps, raycast lidar, and CARLA-class driving sim are **not** implemented — landed: deterministic bicycle integration + `AutoSensorSpec` (64 rays, 640×480) per tick.

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_automotive.html`
