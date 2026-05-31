# Release notes — World Studio SIM-5 sensor bus (2026-05-31)

**Plan todo:** `wsm-w1-sim-sensors`  
**Work packages:** WP-SIM-05

## Summary

Native `li-sim-sensors` raycast bus stub with proved hit bounds on `SimSessionStub`. Automotive and robotics studio profiles step through `studio_sim_sensor_step_hook` → `sim_sensor_session_bus_step` before `sim_step` and replay metadata.

## Proof

```bash
lic check packages/li-sim-sensors/li-tests/smoke/sensor_bus_raycast_contract.li
lic check packages/li-studio/li-tests/smoke/studio_sim_sensor_step_hook.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
./scripts/world-studio-plan-gates.sh
./scripts/world-studio-runnable-gate.sh
```

## Native-only

No HTML studio runtime; `deploy/studio-demo/` remains marketing archive only.
