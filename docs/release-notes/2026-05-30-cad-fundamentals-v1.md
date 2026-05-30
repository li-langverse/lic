# CAD fundamentals v1 (2026-05-30)

## Summary

AL-4 / `cad_fundamentals` handoff: canonical gap doc in lic, thin `li-geometry` package scaffold (PH-GEOM stubs).

## Stub to Real

| API | Stub (v1) | Real (later) | Verification |
|-----|-----------|--------------|--------------|
| geom_orient3d_class_* | enum constants | CGAL exact predicates | mesh_predicates_stub.li |
| geom_mesh_watertight_stub | always 1 | Manifold-class boolean | builds.li |
| geom_vec3_unit_x | math Vec3 | shared with std geometry slice | geometry_smoke() |

## Artifacts

- `docs/ecosystem/cad-fundamentals.md` — merged from li-language; handoff `6e07933a-23ef-46f8-a2e5-c6070c239113`
- `packages/li-geometry` — `import geometry`, smokes under `li-tests/smoke/`
- `docs/ecosystem/algorithms-and-libraries-plan.md` — AL-4 canonical link

## Gates

```bash
test -f docs/ecosystem/cad-fundamentals.md
test -f packages/li-geometry/src/lib.li
grep -q li-geometry packages/li.toml
# With lic built:
# LIC=./build/compiler/lic/lic
# "$LIC" check --allow-open-vc packages/li-geometry/li-tests/smoke/builds.li
```

Swarm run: `code_implementer-1780121843375` · agent: `code_implementer`
