# CAD fundamentals v1 (types-only slice)

**Handoff:** `cad_fundamentals` · **Research session:** goal_researcher `6e07933a`

## Shipped

- Gap table: `docs/game-dev/PH-CAD-fundamentals-gap-table.md` (OpenCascade, CGAL, Manifold reference rows)
- Package `li-cad` (`import cad`): `CadVec3`, `CadTriangle`, `CadMesh`, area/degenerate contracts
- Tier-0: `cad_eps_area_sq()` + `cad_triangle_is_degenerate`
- Smokes: `packages/li-cad/li-tests/smoke/`

## Stub → real (honest)

| API | v1 | Next |
|-----|-----|------|
| `cad_kernel_*_stub` | int tags | B-rep/mesh kernel FFI (human-gated) |
| `cad_mesh_new` | empty mesh | triangle buffer + validation |
| Constraints | — | Wave 2 types |

## Verification

```bash
test -f docs/game-dev/PH-CAD-fundamentals-gap-table.md
test -f packages/li-cad/src/lib.li
# With lic built:
# LIC=./build/compiler/lic/lic
# for s in packages/li-cad/li-tests/smoke/*.li; do "$LIC" check --allow-open-vc "$s"; done
```

**Agent run:** `code_implementer-1780122175546`
