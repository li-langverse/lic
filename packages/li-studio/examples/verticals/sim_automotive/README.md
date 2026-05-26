# Studio vertical: `sim_automotive`

**Focus:** Profile chip + `studio_sim_step_hook` bicycle-model tick stub (`sim.automotive`).

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
lic check packages/li-sim-automotive/li-tests/smoke/tick_stub.li
lic check li-tests/composable/import_sim_automotive_workspace.li
```

## Honest status

Maps, sensor raycast, and CARLA-class driving sim are **not** implemented — only profile bridge + per-tick `run_auto_bicycle_smoke` checksum.

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_automotive.html`
