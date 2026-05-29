# li-sim-robotics

Domain profile stub for **sim_robotics** (World Studio profile id **4**, sim contract **4**).

Arms, mobile bases, and factory cells land here in PH-SIM follow-ups; wires `sim.robotics` against `li-sim` contracts.

v1 (`robotics_systems` goal): 2-DOF FK/workspace, deterministic **robo_plan_rrt** smoke (algo **803**), IK jacobian smoke (**802**). Tier-2 benches still use C oracles under `benchmarks/tier2_physics/robo_*`.

## Build

```bash
lic build src/lib.li -o li-sim-robotics
lic check packages/li-sim-robotics/li-tests/smoke/builds.li
lic check packages/li-sim-robotics/li-tests/smoke/plan_rrt.li
lic check li-tests/composable/import_sim_robotics_run.li
```

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-sim-robotics` |
| Studio profile | `sim_robotics` → `li_sim_profile_from_studio_id(4)` |
| Org repo | https://github.com/li-langverse/li-sim-robotics |

## License

Apache-2.0 OR MIT
