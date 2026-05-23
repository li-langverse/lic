# li-sim-robotics

**PH-ROBO** — `sim_robotics` Studio workspace profile and PH-ROBO phase tracker stubs.

**Status:** `workload_class=stub` — profile + tick counter only; not Gazebo/Isaac Sim/MoveIt/Drake parity.

## Import

```li
import sim.robotics
```

## Bench

- Registry: [robotics.toml](../../benchmarks/competitive/robotics.toml)
- Composable: `li-tests/composable/import_sim_robotics_workspace.li`
- Vertical: `robo_workspace` in [verticals.toml](../../benchmarks/competitive/verticals.toml)

## Build

```bash
lic build src/lib.li -o li-sim-robotics
```

| Field | Value |
|-------|-------|
| Package | `PKG-li-sim-robotics` |
| Program | [PH-ROBO](../../docs/game-dev/PH-world-studio-program.md) |
| RFC | [li-sim-robotics-rfc.md](../../docs/game-dev/specs/li-sim-robotics-rfc.md) |
| Org repo | https://github.com/li-langverse/li-sim-robotics |
