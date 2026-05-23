# RFC: li-sim-robotics (PH-ROBO)

**Status:** Draft stub (`workload_class=stub`)  
**Date:** 2026-05  
**Vision:** [world-studio-vision.md](../world-studio-vision.md) §10 Robotics  
**Program:** [PH-world-studio-program.md](../PH-world-studio-program.md) — **PH-ROBO** ROBO-0…5 (depends **PH-SIM-1**)

## Problem

Robotics simulation (manipulators, mobile bases, factory cells) needs a **`sim_robotics`** Studio profile and package surface aligned with game rigid-body physics, without claiming Gazebo / Isaac Sim / MoveIt / Drake parity.

## Proposal

| Layer | Deliverable | Status |
|-------|-------------|--------|
| Package | `sim.robotics` (`li-sim-robotics`) | **landed** — workspace state + PH-ROBO phase chrome |
| Bench | `robo_workspace` in [robotics.toml](../../../benchmarks/competitive/robotics.toml) | **stub** — composable_only |
| Composable | `import_sim_robotics_workspace.li` | **landed** |
| Registry | `verticals.toml` id=`robo_workspace` | **landed** |
| Physics | `physics.rigid` integrate + collision | tier-2 proxy (gaming_rigid); robotics timed row **TBD** |

### PH-ROBO phases (tracker)

| Phase | ID | This slice |
|-------|-----|------------|
| 0 | ROBO-0 | Workspace profile + composable smoke (`robo_ph_robo_phase_0`) |
| 1 | ROBO-1 | Tick advance → phase 1 (`robo_workspace_advance`) |
| 2–5 | ROBO-2…5 | Phase chrome through tick 5 | **stub** — no ROS2/MoveIt FFI |
| — | — | Trusted Gazebo/Drake oracle | **open** (Wave E) |

## Li syntax

```li
import sim.robotics

var w: RoboticsWorkspaceState = robo_workspace_init(6)
var w1: RoboticsWorkspaceState = robo_workspace_advance(w, robo_event_advance_tick())
```

Exported APIs use `requires` / `ensures` / `decreases` on `packages/li-sim-robotics/src/lib.li`.

## Proof / trust

- **Proved:** workspace init invariants, tick monotonicity, profile id constant.
- **Trusted:** none in this slice.
- **Stub:** full manipulator kinematics, ROS2 bridge, MoveIt planning — not implemented.

## Dependencies

- `physics.rigid` — shared rigid-body stack (see `gaming_rigid` vertical)
- PH-SIM-1 `li-sim` step API — **not** landed; workspace tick is native stub counter

## Honesty

Cite [verticals.toml](../../../benchmarks/competitive/verticals.toml) `robo_workspace` with `workload_class=stub`. No Gazebo/Isaac Sim/MoveIt/Drake performance claims in CI or docs.

## Open questions

- [ ] ROS2 bridge trusted boundary (ROBO-4)
- [ ] MoveIt-class motion planning FFI (ROBO-5)
- [ ] Timed bench row vs `physics.rigid` tier-2 proxy
