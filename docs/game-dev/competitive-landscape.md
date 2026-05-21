# Competitive landscape — Li World Studio / Li Engine

**Status:** Planning snapshot (rev. 2026-05-21)  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**Algorithms / libs schedule:** [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md)  
**Layer B registry:** `benchmarks/competitive/verticals.toml`

| Area | Incumbent | Li beat condition |
|------|-----------|-------------------|
| Game engines | Unity, Unreal, Godot | Diffable Li worlds + `lic build` + agents |
| **MMORPGs** | Photon, Spatial, custom shards | **PH-MMO:** proved shard logic + `store.realtime` facade — [plan](mmorpg-deployment-plan.md) |
| Driving sim | CARLA, AirSim | **No fork** — `sim_automotive` on Li Engine |
| Robotics | Gazebo, Isaac Sim | Same engine as games; optional ROS2 bridge |
| AM slicers | Cura, PrusaSlicer | Sim + warp proof + **export to printer** in Studio |
| Scientific viz | ParaView, MATLAB | In-engine graphics + PH-PUB repro bundles |
| MD / CFD | GROMACS, OpenFOAM | Live tier-2 benches in viewport |
| Drug discovery | Roche Lab-in-the-Loop, BioNeMo | Open projects + adaptive GUI + QM in Li |
| **Bioengineering** | Benchling, Rosetta, ProteinMPNN, COMSOL Biokinetics | **PH-BIOENG:** DBTL on same LITL spine as drug design + `lic build` + scorecard — [plan](competitive-bioengineering-plan.md) |
| QM packages | Gaussian, ORCA, Psi4 | `li-chem` easy API + native/GPU + trusted drivers |
| GPU lock-in | CUDA-only stacks | **ROCm/HIP** + LKIR |
| Agents | Ad-hoc Copilot | MCP + `@cursor/sdk` + mandatory `lic build` |

## Algorithm & library competitors (by vertical)

High-level product rows are above; **kernel-level** tracking lives in `verticals.toml`. Gaps to fill next:

| Vertical | Incumbent libs (algorithm layer) | Li package | Bench / oracle status |
|----------|----------------------------------|------------|------------------------|
| HPC MD | LAMMPS, GROMACS | `physics.particles` | tier-2 cpp; **external oracle TBD** |
| CFD | OpenFOAM, Fluent solvers | `physics.fluids` | heat/wave proxies only |
| QM | Psi4, ORCA, Gaussian, xTB | `chem.dft` | trusted FFI plan; stub |
| FEA | CalculiX, FEniCS | *(PH-SCI — split RFC needed)* | none |
| CAD | OCCT, CGAL, Manifold | *(PKG TBD)* | gap doc in li-language |
| Slicer / AM | Cura, Prusa, Orca | `sim.additive` | thermal proxy; no toolpath oracle |
| Protein | Rosetta, ProteinMPNN, RFdiffusion | `bioeng` | `bioengineering.toml` stub |
| Cinematic encode | ffmpeg, Resolve export | `studio.publish` | stub; UX intel only |
| DCC mesh | Blender bpy, Houdini HDK | `assets` | glTF stub |

**HPC language competitors** (C++/Rust/Julia/NumPy): [registry.toml](../../benchmarks/competitive/registry.toml).

_Update quarterly — sync `verticals.toml` `last_reviewed` and [algorithms-and-libraries-plan.md](../ecosystem/algorithms-and-libraries-plan.md)._
