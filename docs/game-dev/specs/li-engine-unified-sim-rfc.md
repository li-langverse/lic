# RFC: Li Engine unified simulation

**Status:** Draft  
**Track:** PH-SIM  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Industry forks game engines for CARLA, GROMACS GUIs, and slicers — drift and duplicate physics.

## Proposal

One **Li Engine** core (`li-world`, `li-scene`, `li-physics-*`, `li-render`) with **runtime profiles**:

`game` | `sim_rl` | `sim_automotive` | `sim_robotics` | `sim_additive` | `sim_scientific` | `sim_drug_design`

**Law modes** (orthogonal to profile): `realistic` | `arbitrary` | `hybrid` — see [arbitrary-physics-laws-rfc.md](arbitrary-physics-laws-rfc.md).

**`li-sim`** exposes:

```li
def sim_reset(world: SimWorld) -> unit
def sim_step(world: SimWorld) -> unit
def sim_set_law_mode(world: SimWorld, mode: int, custom_law_id: int) -> unit
def sim_step_arbitrary(world: SimWorld) -> unit
```

With **`physics.custom`**: `custom_law_apply(law_id, state, dt)` for unphysical or user-defined rules.

`ml.rl.EnvPool` calls `sim_step` — no duplicate Gym physics.

## Syntax

`def` for all public APIs; contracts required on `sim.*` exports. Arbitrary laws must **not** claim false conservation in `ensures`.

## Phases

SIM-0 (RFC) → SIM-1 step/reset → SIM-2 replay → SIM-3 RL hookup → **SIM-4 custom law registry** (PH-PHYS-CUSTOM).
