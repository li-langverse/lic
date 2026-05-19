# RFC: Scientific simulation + viewport viz (PH-SCI)

**Status:** Draft  
**Track:** PH-SCI  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

CFD, MD, heat, and orbital workflows need tier-2 physics **and** field visualization in one engine viewport — not a separate VTK-only tool chain.

## Proposal

**`li-sim-scientific`** (`import sim.scientific`):

- `SimVizFrame` — field samples per timestep  
- `sim_viz_push_sample` — viewport feed hook  
- `scientific_run_stub` — ties to `li-physics-*` tier 1–3  

Runs inside World Studio; benches from `li-tests/hpc_competitive` link here later.

## Phases

SCI-0 stubs (landed) → SCI-1 real field buffers → SCI-2 VTK/HDF5 export (PH-PUB).

## Dependencies

`li-physics-*`, `li-sim`, PH-UX viewport performance targets.
