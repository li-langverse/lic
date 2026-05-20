# RFC: Robotics simulation (PH-ROBO)

**Status:** Draft  
**Track:** PH-ROBO  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Factory digital twins and manipulator RL need the **same** rigid-body stack as games, not a parallel Bullet-only fork.

## Proposal

**`li-sim-robotics`** (`import sim.robotics`):

- `RobotCell` — joints + optional mobile base  
- `robotics_step_stub` — advances cell; future → `physics.runtime`  
- ROS2 bridge (trusted FFI) in ROBO-3+

## Phases

ROBO-0 stubs → ROBO-1 IK hooks → ROBO-2 ROS2 bridge.

## Dependencies

PH-SIM-1, `li-physics-rigid`, optional `li-ml` for RL env pools.
