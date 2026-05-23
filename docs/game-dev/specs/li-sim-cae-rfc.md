# RFC: Engineering / CAE — FEA & CFD (PH-CAE)

**Status:** Draft stub (2026-05-23)  
**Track:** PH-CAE  
**Split from:** PH-SCI ([sim-viz-scientific-rfc.md](sim-viz-scientific-rfc.md) — MD, heat, orbital, viz only)  
**Fundamentals:** [engineering-cae-fundamentals.md](../../ecosystem/engineering-cae-fundamentals.md)  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Engineering simulation (structural FEA, incompressible CFD) was folded into **PH-SCI**, blurring molecular dynamics / generic heat PDE work with COMSOL/OpenFOAM-class workloads. Layer B registry and Studio profiles need **explicit FEA vs CFD** tracking and honesty labels before Wave D kernel scale-up.

## Proposal

**Profile:** `sim_scientific` (shared shell with PH-SCI) · **Program:** PH-CAE

| Subsystem | Package | Canonical kernel (target) | `verticals.toml` id |
|-----------|---------|---------------------------|---------------------|
| FEA | `sim.scientific`, `linalg` | linear elasticity assembly + solve | `fea_linear_elasticity` |
| CFD | `sim.scientific`, `physics.fluids` | lid-driven cavity, SIMPLE iteration | `cfd_lid_driven_cavity` |
| Viz | `sim.viz` | field overlays, boundary layers | (reuse `scientific_viz`) |

```li
# illustrative — contracts required on real exports
import sim.scientific

def cae_workload_class_stub() -> int
  requires true
  ensures result == 0
=
  0
```

**Studio:** ParaView-class pipeline for stress / velocity fields ([UX-06](../competitive-intel/ui-ux-by-dimension.md#ux-06--scientific-visualization)); no COMSOL UI parity claims.

## Phases (PH-CAE)

| ID | Deliverable |
|----|-------------|
| CAE-0 | Fundamentals doc + registry rows + this RFC |
| CAE-1 | FEA bench stub (`fea_linear_elasticity`) |
| CAE-2 | CFD cavity bench stub (`cfd_lid_driven_cavity`) |
| CAE-3 | Mesh + BC types |
| CAE-4 | Turbulence API stub |
| CAE-5 | Trusted CalculiX / OpenFOAM FFI (Wave E) |

## Li syntax

Python-style `def`; `requires` / `ensures` / `decreases` on exported APIs. Explicit linear algebra only — **no NumPy broadcasting**.

## Proof / trust

| Component | Proved | Trusted (T5 FFI) |
|-----------|--------|------------------|
| Small dense FEA | `linalg` + contract corpus (future) | CalculiX assembly export |
| Explicit CFD step | CFL + residual bounds (future) | OpenFOAM case driver |
| Full industrial mesh | — | Gmsh / Salome (deferred) |

Until Wave A exit: label **`workload_class=stub`** in docs and PRs.

## Dependencies

- [PH-world-studio-program.md](../PH-world-studio-program.md) — PH-CAE after PH-SCI-2 (shared tier-2 physics)
- [algorithms-and-libraries-plan.md](../../ecosystem/algorithms-and-libraries-plan.md) AL-5
- [vertical-algorithm-catalog.md](../../ecosystem/vertical-algorithm-catalog.md)

## Open questions

- [ ] Single `li-sim-cae` package vs extend `sim.scientific` only?
- [ ] First external oracle: CalculiX vs OpenFOAM for CAE-5?
- [ ] Coupling FEA thermal ↔ `pde_heat_2d` (PH-AM path) — document in CAE-3?
