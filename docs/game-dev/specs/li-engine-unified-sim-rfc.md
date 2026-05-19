# RFC: Li Engine unified simulation

**Status:** Draft  
**Track:** PH-SIM  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Industry forks game engines for CARLA, GROMACS GUIs, and slicers — drift and duplicate physics.

## Proposal

One **Li Engine** core (`li-world`, `li-scene`, `li-physics-*`, `li-render`) with **runtime profiles**:

`game` | `sim_rl` | `sim_automotive` | `sim_robotics` | `sim_additive` | `sim_scientific` | `sim_drug_design`

**`li-sim`** exposes:

```li
def sim_reset(world: SimWorld) -> unit
def sim_step(world: SimWorld, dt: float) -> unit
```

`ml.rl.EnvPool` calls `sim_step` — no duplicate Gym physics.

## Syntax

`def` for all public APIs; contracts required on `sim.*` exports.

## Phases

SIM-0 (this RFC) → SIM-1 step/reset → SIM-2 replay → SIM-3 RL hookup.
