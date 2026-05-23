# Traceability — PKG-li-std-physics-rigid

<!-- DOC-traceability-PKG-li-std-physics-rigid -->

| Type | ID | Artifact |
|------|-----|----------|
| Package | PKG-li-std-physics-rigid | This repository |
| Phase | PH-Pkg | [Package scaffold](https://github.com/li-langverse/li-language/blob/dev/docs/superpowers/plans/2026-05-16-li-package-scaffold.md) |
| Test | T-PKG-li-std-physics-rigid-smoke | `li-tests/smoke/builds.li` |
| Composable | T-composable-import-physics-rigid-gaming | `li-tests/composable/import_physics_rigid_gaming.li` |
| Vertical | `gaming_rigid` | [verticals.toml](../../../benchmarks/competitive/verticals.toml) · [world-studio.toml](../../../benchmarks/competitive/world-studio.toml) |
| Tier-2 verify | `rigid_body_stack` | [verify.py](../../../benchmarks/harness/verify.py) · `rigid_stack_core.c` |

## Requirements

Link design-spec `REQ-*` items when this package implements normative language or std behavior.

## Releases

Update `CHANGELOG.md` and `li.toml` `version` together; tag `vX.Y.Z` on GitHub.
