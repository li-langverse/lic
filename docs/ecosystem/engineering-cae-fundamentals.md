# Engineering / CAE fundamentals — Li ecosystem (AL-5)

**Status:** Active (2026-05-23) — FEA/CFD split from **PH-SCI**; **`workload_class=stub`** until Wave A exit.  
**Program:** [PH-CAE](../game-dev/world-studio-vision.md#115-engineering--cae-ph-cae) (§11.5) · [PH-world-studio-program.md](../game-dev/PH-world-studio-program.md)  
**RFC:** [li-sim-cae-rfc.md](../game-dev/specs/li-sim-cae-rfc.md)  
**Packages:** `sim.scientific`, `physics.fluids`, `physics.core`, `voxel`, `math`  
**Plan:** [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §3 · AL-5

Gate: `./scripts/check-engineering-cae-rfc.sh`

---

## North star

World Studio **`sim_scientific`** profile covers **engineering simulation** (FEA structural, CFD fluids) as a **separate program track** from molecular dynamics and generic PDE heat ([PH-SCI](../game-dev/specs/sim-viz-scientific-rfc.md)). Shared numerics live in `math` / `linalg`; kernels stay thin until Wave A.

## Honesty

- **`workload_class=stub`** — no COMSOL / ANSYS / OpenFOAM / CalculiX parity claims in CI or docs.
- Layer B rows: `fea_linear_elasticity`, `cfd_lid_driven_cavity` in [verticals.toml](../../benchmarks/competitive/verticals.toml).
- **`pde_heat_2d`** proves explicit heat stencil only — **not** CFD or FEA ([vertical-algorithm-catalog.md](vertical-algorithm-catalog.md) §`pde_heat_2d`).
- Wave A: do not scale external solver FFI until [provability-gaps](../verification/provability-gaps.md) 2e/2f are green.

---

## FEA vs CFD split (from PH-SCI)

| Track | Domain | Incumbent refs | Li v1 stance | Registry `id` |
|-------|--------|----------------|--------------|---------------|
| **FEA** | Linear elasticity, mesh solve | CalculiX, ANSYS Mechanical, SimScale | Stiffness assembly + small-system solve stub; explicit `linalg` only | `fea_linear_elasticity` |
| **CFD** | Incompressible flow, cavity benchmarks | OpenFOAM, COMSOL CFD, PETSc | Lid-driven cavity + SIMPLE-class iteration stub | `cfd_lid_driven_cavity` |
| **Shared** | Mesh, BCs, materials | Gmsh, Salome | Types on `voxel` / future `geometry` bridge; no full mesher port |
| **Out of PH-SCI** | MD, orbital, generic heat | GROMACS, `heat_equation_2d` | Stays under **PH-SCI** — see [sim-viz-scientific-rfc.md](../game-dev/specs/sim-viz-scientific-rfc.md) |

---

## Learned from incumbents

| System | Takeaway for Li |
|--------|-----------------|
| **CalculiX** | Sparse assembly + linear solve; trusted FFI behind T5 audit, not monolithic port |
| **OpenFOAM** | Operator-split pressure–velocity; canonical lid cavity for regression |
| **COMSOL / SimScale** | Multiphysics UI patterns → Studio `sim.viz` + PH-UX; algorithms tracked in Layer B only |
| **PETSc** | Distributed solve deferred; tier-0 explicit small matrices first |

---

## Li package surface today (stub)

No dedicated `li-sim-cae` package yet — engineering kernels target **`import sim.scientific`** + `physics.fluids` when benches land.

Planned composable (Wave D+): `li-tests/composable/import_cae_workload_class_stub.li` — returns `cae_workload_class_stub() → 0`.

Every export: mandatory contracts; explicit linear algebra — **no NumPy broadcasting**; matching shapes or compile fail.

---

## PH-CAE milestones

| Phase | ID | Deliverable | Status |
|-------|-----|-------------|--------|
| 0 | CAE-0 | This doc + RFC + PH tracker + `verticals.toml` FEA/CFD rows | **done (2026-05-23)** |
| 1 | CAE-1 | `fea_linear_elasticity` tier-2 bench stub | open |
| 2 | CAE-2 | `cfd_lid_driven_cavity` tier-2 bench stub | open |
| 3 | CAE-3 | Mesh + BC types on `voxel` / `geometry` | open |
| 4 | CAE-4 | Turbulence model API stub (k–ε class) | open |
| 5 | CAE-5 | Trusted CalculiX/OpenFOAM FFI pilot | open (Wave E) |

---

## Tier-0 numerics

- Small dense solves via `linalg` / explicit loops; document conditioning policy before production FEA.
- Reuse `math` / `math.numerics` patterns from [cad-fundamentals.md](cad-fundamentals.md).
- CFL / stability guards for explicit CFD steps mirror `pde_heat_2d` discipline.

---

## Vertical / bench linkage

| Registry | Row | Notes |
|----------|-----|-------|
| [verticals.toml](../../benchmarks/competitive/verticals.toml) | `fea_linear_elasticity`, `cfd_lid_driven_cavity` | **stub**; no external oracle column yet |
| [vertical-algorithm-catalog.md](vertical-algorithm-catalog.md) | §`fea_linear_elasticity`, §`cfd_lid_driven_cavity` | Honesty per row |
| Studio matrix §3 | Engineering / CAE | RFC + registry; bench **open** |

---

## Out of scope (v1)

Full multiphysics coupling, turbulence production runs, CAD-integrated mesher UI, “GROMACS-class” or “Gaussian-class” marketing for CAE.

---

## Evidence for implement PRs

- Cite **PH-CAE** phase id and `workload_class=stub` in the PR body.
- Cite `verticals.toml` row `id` for FEA vs CFD claims.
- Run `./scripts/check-engineering-cae-rfc.sh` with ecosystem doc gates.

---

## Related

- [PH-world-studio-program.md](../game-dev/PH-world-studio-program.md)
- [world-studio-vision.md](../game-dev/world-studio-vision.md)
- [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §3 Engineering row
