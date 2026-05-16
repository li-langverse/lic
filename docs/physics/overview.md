# Li physics module overview

Physics for the Li game engine is delivered as **`li-std-physics*`** packages on top of **`li-std-math`** and **`li-std-numerics`**.

**Quick start:** [GAME_DEV.md](./GAME_DEV.md) (packages, tier-2 benches, engine checklist).

## Fidelity tiers

| Tier | Name | Typical use |
|------|------|-------------|
| T0 | Arcade | 60+ FPS, PBD, semi-implicit Euler |
| T1 | Simulation | Verlet, SPH, weather advection |
| T2 | Scientific | FDTD, TDSE, weak-field GR |
| T3 | Research | Offline HEP toys, full MD research |

Scenes select a **`PhysicsProfile`** (`tier`, `dt`, `substeps`, **`NumericalTargets`**).

## Packages

| Package | Role |
|---------|------|
| `li-std-math` | Vec3, Quat, Mat4, array dot/sum |
| `li-std-numerics` | Integrators, three-body reference |
| `li-std-physics-core` | Profiles, tier defaults |
| `li-std-physics-rigid` | Rigid bodies, PGS stub |
| `li-std-physics-runtime` | `PhysicsWorld`, `physics_step` |
| `li-std-physics-particles` | Emitters, MD SoA |
| `li-std-physics-fluids` | SPH, heat, cloth PBD |
| `li-std-physics-weather` | Advection/diffusion wind |
| `li-std-physics-aero` | Atmosphere, orbits |
| `li-std-physics-chem` | Reactions, passive combustion |
| `li-std-physics-em` | Coulomb, FDTD, Poisson |
| `li-std-physics-quantum` | TDSE 1D hooks |
| `li-std-physics-relativity` | SR + Schwarzschild factor |
| `li-std-physics-hep` | Toy MC (education) |

## Benchmarks

Tier-2 kernels live under `lic/benchmarks/tier2_physics/`. Status is tracked on the [benchmarks dashboard](https://li-langverse.github.io/benchmarks/).

## Numerical policy

See [numerical-policy.md](numerical-policy.md) for compile-time method selection (planned language phase **PHY-n**).
