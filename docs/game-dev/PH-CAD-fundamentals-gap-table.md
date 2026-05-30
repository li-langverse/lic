# PH-CAD fundamentals — gap table (v1)

**Handoff:** `cad_fundamentals` (goal_researcher) · **North star:** proof-first geometry/CAD for scientific Li.

## Mature systems (reference only — no FFI in v1)

| System | Kernel | Constraints | IO | Notes |
|--------|--------|-------------|-----|-------|
| OpenCascade | B-rep + NURBS | variational | STEP/IGES/BREP | industrial CAD baseline |
| CGAL | meshes + exact predicates | combinatorial | OFF/OBJ | strong degeneracy handling |
| Manifold | watertight mesh | implicit repair | STL/3MF | fast boolean mesh ops |

## Li v1 slice (`packages/li-cad`)

| Gap | v1 contract | Wave |
|-----|-------------|------|
| Kernel | `CadKernelKind` tag + `cad_version()` — no B-rep FFI | 1 (this PR) |
| Mesh | `CadVec3`, `CadTriangle`, `CadMesh` + area/degenerate predicates | 1 |
| Constraints | deferred — types only in tracker | 2 |
| IO (STEP/IGES) | out of scope | 3+ |

## Tier-0 numerics (stability)

- Triangle area uses cross-product magnitude; `cad_triangle_area_sq` compared to `cad_eps_area_sq()` (1e-24 f32 reference).
- Degenerate triangles: area² ≤ ε; callers must not assume non-zero area for collision/CFD without checking `cad_triangle_is_degenerate`.

## Proof gate

- All public defs carry `requires` / `ensures`; no `trusted.lean` changes in v1.
- Smokes: `packages/li-cad/li-tests/smoke/` (`lic check --allow-open-vc` when compiler built).

## Tracker

Next WPs: constraint sketch types (Wave 2), optional `lig` tessellation hook (Wave 3) — see `packages/li-cad/README.md`.
