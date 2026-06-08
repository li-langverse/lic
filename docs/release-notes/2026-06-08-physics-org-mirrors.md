# Physics org mirrors published (lic#50)

**Date:** 2026-06-08  
**Repo:** lic + 12 org mirrors  
**Type:** Ecosystem — org mirror publish

## Summary

Published **12 official `li-physics-*` org mirrors** for the physics package family under `packages/li-physics-*`. Each mirror includes `ci.yml` on `main` (smoke: `lic check` + `lic build li-tests/smoke/builds.li`).

## Mirrors

| Monorepo folder | Org repo |
|-----------------|----------|
| `li-physics-core` | `li-langverse/li-physics-core` |
| `li-physics-rigid` | `li-langverse/li-physics-rigid` |
| `li-physics-runtime` | `li-langverse/li-physics-runtime` |
| `li-physics-particles` | `li-langverse/li-physics-particles` |
| `li-physics-fluids` | `li-langverse/li-physics-fluids` |
| `li-physics-weather` | `li-langverse/li-physics-weather` |
| `li-physics-aero` | `li-langverse/li-physics-aero` |
| `li-physics-chem` | `li-langverse/li-physics-chem` |
| `li-physics-em` | `li-langverse/li-physics-em` |
| `li-physics-quantum` | `li-langverse/li-physics-quantum` |
| `li-physics-relativity` | `li-langverse/li-physics-relativity` |
| `li-physics-hep` | `li-langverse/li-physics-hep` |

## Changes in lic

- Aligned stale `li-std-physics-*` metadata → `li-physics-*` in README/PUBLISH/traceability
- Registered mirrors in `.github/li-downstream-repos.txt`
- Added `scripts/push-physics-mirrors.sh` batch helper

## Related

- Issue: https://github.com/li-langverse/lic/issues/50
- Plan: `docs/superpowers/plans/2026-06-07-li-physics-org-mirrors-plan.md`
- Domain API depth: lic#14 (deferred)

## north_star_fit

HPC/scientific computing ecosystem · PH-5b tier-2 physics · proof-before-perf (CI gates on mirrors)
