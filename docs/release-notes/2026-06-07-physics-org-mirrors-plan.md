# Physics org mirrors plan (lic#50)

**Date:** 2026-06-07  
**Repo:** lic  
**Type:** Planning slice — no mirror push in this PR

## Summary

Drafts implementation plan to publish **12 `li-physics-*` org mirrors** for packages already scaffolded in `packages/li-physics-*`. Clarifies canonical naming (`li-physics-*`, not legacy `li-std-physics-*`) and separates mirror CI work from domain API expansion (lic#14).

## Artifacts

- `docs/superpowers/plans/2026-06-07-li-physics-org-mirrors-plan.md`

## Next steps (after `plan-approved`)

1. Align stale README/PUBLISH metadata
2. Run `push-official-package-repo.sh --create` for all 12 packages
3. Update `tooling-catalog.md` in **benchmarks** sibling PR
4. Register mirrors in `li-downstream-repos.txt` and roadmap `official-packages.md`
