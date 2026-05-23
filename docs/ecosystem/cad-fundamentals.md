# CAD fundamentals — Li ecosystem (AL-4)

**Status:** Active (2026-05-23) — gap analysis + `geometry` package linkage; **`workload_class=stub`** until Wave A exit.  
**Program:** [PH-GEO](../game-dev/world-studio-vision.md#145-cad--mesh-geometry-ph-geo) · [PH-world-studio-program.md](../game-dev/PH-world-studio-program.md)  
**Package:** [`packages/li-geometry`](../../packages/li-geometry/README.md) — `import geometry`; `geometry_workload_class_stub()` → 0  
**Plan:** [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §7.4 · AL-4  
**Provenance:** merged from [li-language `cad-fundamentals`](https://github.com/li-langverse/li-language/blob/dev/docs/ecosystem/cad-fundamentals.md) (2026-05-23)

Gate: `./scripts/check-cad-fundamentals.sh`

---

## North star

Geometry/CAD support for World Studio and scientific profiles: small **`packages/`** slices (`geometry`, `voxel`, `math`) — **not** a monolithic OCCT port ([algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §7.6).

## Honesty

- **`workload_class=stub`** — no COMSOL / Fusion / OCCT / CGAL parity claims in CI or docs.
- Bench row: **none** today ([vertical matrix](algorithms-and-libraries-plan.md) §3); proof today is composable + tier-0 numerics only.
- Wave A: do not scale kernel FFI until [provability-gaps](../verification/provability-gaps.md) 2e/2f are green.

---

## Gap table (v1)

| Area | Mature references | Li v1 stance |
|------|-------------------|--------------|
| B-rep / solid modeling | OpenCascade, CGAL | Document gaps; trusted FFI only behind explicit PKG + human review |
| Mesh / manifold ops | Manifold, libigl | **`import geometry`** — `mesh_orient2d`, `mesh_orient3d`, `mesh_incircle2d` (float determinants; exact filters deferred) |
| Constraints / sketches | SolveSpace, FreeCAD | Defer; types-only sketch in a future API |
| IO (STEP/IGES) | OCCT | **Out of scope** v1 |
| CAD editor UI | Fusion, Onshape | Studio import via PH-GD / PH-AM; no native kernel UI |

---

## Learned from incumbents

| System | Takeaway for Li |
|--------|-----------------|
| **OpenCascade** | Heavy kernel; thin contract-backed wrappers only (T5 trusted FFI) |
| **CGAL** | Exact predicates + epsilon policies → tier-0 numerics + `math` discipline |
| **Manifold** | Fast mesh booleans; reference for future SIMD-friendly batch APIs (GEO-2+) |

---

## Li package surface today (AL-13 / PH-GEO-1)

Composable smoke: `li-tests/composable/import_geometry_mesh_predicates.li`

Types in `packages/li-geometry/src/lib.li`:

- `GeoVec2`, `GeoVec3`, `MeshTriangle2`, `MeshTet3`
- `mesh_orient2d`, `mesh_orient3d`, `mesh_incircle2d`

```li
# illustrative — see package for full contracts
var t: MeshTriangle2 = mesh_triangle2(geo_vec2(0.0, 0.0), geo_vec2(1.0, 0.0), geo_vec2(0.0, 1.0))
var o: float = mesh_orient2d(t)
```

Every export: mandatory contracts; no `trusted.lean` changes in agent PRs.

---

## PH-GEO milestones

| Phase | ID | Deliverable | Status |
|-------|-----|-------------|--------|
| 0 | GEO-0 | This doc + PH tracker row | **done (2026-05-23)** |
| 1 | GEO-1 | `import geometry` mesh predicates | **done (AL-13)** |
| 2 | GEO-2 | Mesh boolean API stub | open |
| 3 | GEO-3 | `voxel` / PH-AM mesh bridge | open |
| 4 | GEO-4 | Trusted OCCT/CGAL FFI pilot | open (Wave E) |
| 5 | GEO-5 | STEP/IGES import | deferred |

---

## Tier-0 numerics

- Document epsilon policy for degenerate triangles and coplanar facets before shipping float geometry at scale.
- Reuse `math` / `math.numerics` patterns; explicit linear algebra only — **no NumPy broadcasting** in Li kernels.
- Do not weaken `stdlib_seal` or coverage tiers for geometry promotion.

---

## Vertical / bench linkage

| Registry | Row | Notes |
|----------|-----|-------|
| [verticals.toml](../../benchmarks/competitive/verticals.toml) | (no CAD row yet) | Add when an oracle exists |
| [vertical-algorithm-catalog.md](vertical-algorithm-catalog.md) | — | Expand when `[[vertical]]` lands |
| Studio matrix §3 | CAD / mechanical | `geometry.*` target; bench **none** |

---

## Out of scope (v1)

CAD editor UI, STEP/IGES importers, GPU tessellation, standalone `li-cad-kernel` repo.

---

## Evidence for implement PRs

- Cite **PH-GEO** phase id and `workload_class=stub` in the PR body.
- Tests: `li-tests/composable/import_geometry_mesh_predicates.li` or package `lit` ≥80% before `lip` promotion.
- Run `./scripts/check-cad-fundamentals.sh` with ecosystem doc gates.

---

## Related

- [PH-world-studio-program.md](../game-dev/PH-world-studio-program.md)
- [world-studio-vision.md](../game-dev/world-studio-vision.md)
- [Release notes: geometry scaffold](../release-notes/2026-05-23-wave-d-geometry-scaffold.md)
- [PKG-li-geometry traceability](../../packages/li-geometry/docs/traceability.md)
