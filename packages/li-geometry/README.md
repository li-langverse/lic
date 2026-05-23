# li-geometry

CAD/AM mesh predicates — explicit `orient2d` / `orient3d` / `incircle2d` determinants (no NumPy; exact filters deferred).

**Status:** stub (`geometry_workload_class_stub` → 0) until CGAL-class exact arithmetic.

**Program:** [PH-GEO](../../docs/game-dev/world-studio-vision.md#145-cad--mesh-geometry-ph-geo) · [cad-fundamentals.md](../../docs/ecosystem/cad-fundamentals.md)

**Import:** `import geometry` — `mesh_orient2d`, `mesh_orient3d`, `mesh_incircle2d`, smoke helpers.

Li package li-geometry

## Build

```bash
lic build src/lib.li -o li-geometry
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-geometry` |
| Org repo | https://github.com/li-langverse/li-geometry |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
