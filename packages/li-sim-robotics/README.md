# li-sim-robotics

Domain profile stub for **sim_robotics** (World Studio profile id **4**, sim contract **4**).

**ROBO-0 (landed):** `sim_robotics_tick_stub` — one `physics.rigid` semi-implicit step per studio tick (algo **801**). IK, factory cells, and ROS2 remain PH-ROBO follow-ups.

## Build

```bash
lic build src/lib.li -o li-sim-robotics
lic check packages/li-sim-robotics/li-tests/smoke/builds.li
```

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-sim-robotics` |
| Studio profile | `sim_robotics` → `li_sim_profile_from_studio_id(4)` |
| Org repo | https://github.com/li-langverse/li-sim-robotics |

## License

Apache-2.0 OR MIT
