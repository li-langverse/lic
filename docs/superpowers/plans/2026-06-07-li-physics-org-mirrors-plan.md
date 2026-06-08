# Physics package org mirrors — publish 12 `li-physics-*` repos

> **Issue:** [#50](https://github.com/li-langverse/lic/issues/50) · **Related:** [#14](https://github.com/li-langverse/lic/issues/14) (domain API depth)  
> **Vision:** **Provable** (mirror CI runs `lic check` + smoke), **Easy** (composable `import physics.*`), **Fast** (tier-2 kernels after proof — not in this slice)  
> **Learned from:** [repo-naming.md](../../ecosystem/repo-naming.md), [ecosystem governance](2026-05-16-li-ecosystem-governance.md), [package scaffold](2026-05-16-li-package-scaffold.md), [algorithms-and-libraries-plan § Wave C](../../ecosystem/algorithms-and-libraries-plan.md)

## Goal

Publish **12 official org mirrors** for the physics package family already scaffolded under `packages/li-physics-*` in the `lic` monorepo. Each mirror must have **`ci.yml` on `main`**, Dependabot, and ecosystem-upstream hooks per [engineering standards](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md).

This slice is **mirror + CI scaffolding only** — not domain API expansion (tracked separately in #14).

## Naming clarification (issue vs canonical policy)

Issue #50 references `li-std-physics-*` from an older explorer digest. **Canonical policy** ([repo-naming.md](../../ecosystem/repo-naming.md)):

| Import | GitHub repo | Monorepo folder |
|--------|-------------|-----------------|
| `physics.core` | `li-physics-core` | `packages/li-physics-core` |
| `physics.rigid` | `li-physics-rigid` | `packages/li-physics-rigid` |
| … (10 more) | `li-physics-<subdomain>` | `packages/li-physics-<subdomain>` |

**Do not create new repos with `li-std-physics-*` prefix.** Stale `li-std-*` strings in README/PUBLISH.md must be aligned in the implementation PR (via `align-package-repo-names.py` or manual patch).

### Legacy org repos

| Existing repo | Action |
|---------------|--------|
| `li-langverse/physics.runtime` | **Rename** → `li-physics-runtime` (GitHub redirects; human gate) |
| `li-langverse/physics.custom` | **Keep** — distinct PH-PHYS-CUSTOM scope; not in the 12-pack |

## north_star_fit

- **Domain:** HPC / scientific computing + tier-2 gaming physics ecosystem
- **PH:** **5b** (benchmarks & sims), tier-2 physics module track
- **G-***:** **G-physics** (Partial → stays Partial until #14 closes domain APIs; mirrors do not claim Done)
- **Pillars:** proof-first CI gates on every mirror → composable imports → perf work deferred to #14 / bench_improver

## Non-goals

- Filling stub `lib.li` with production domain APIs (#14)
- Weakening benchmark thresholds or catalog honesty
- Creating empty shell repos without smoke CI (packages already have `li-tests/smoke/builds.li`)
- Merging `feat/physics-module-packages` in this slice (separate track per [PUSH_PR.md](../../physics/PUSH_PR.md))
- `trusted.lean` changes

## Current state (2026-06-07 audit)

| Check | Status |
|-------|--------|
| Monorepo folders `packages/li-physics-*` | **12 present** |
| `.github/workflows/ci.yml` per package | **12/12** (`ensure-package-ci.sh` template) |
| Org mirrors `li-langverse/li-physics-*` | **0/12** |
| `github_repo` in `li.toml` | Aligned to `li-physics-*` |
| Stale `li-std-physics-*` in README/PUBLISH | **Some packages** — fix before push |
| `tooling-catalog.md` rows | Missing mirror URLs — update in **benchmarks** PR |

### Package inventory

| Folder | Import | PKG id |
|--------|--------|--------|
| `li-physics-core` | `physics.core` | `PKG-li-physics-core` |
| `li-physics-rigid` | `physics.rigid` | `PKG-li-physics-rigid` |
| `li-physics-runtime` | `physics.runtime` | `PKG-li-physics-runtime` |
| `li-physics-particles` | `physics.particles` | `PKG-li-physics-particles` |
| `li-physics-fluids` | `physics.fluids` | `PKG-li-physics-fluids` |
| `li-physics-weather` | `physics.weather` | `PKG-li-physics-weather` |
| `li-physics-aero` | `physics.aero` | `PKG-li-physics-aero` |
| `li-physics-chem` | `physics.chem` | `PKG-li-physics-chem` |
| `li-physics-em` | `physics.em` | `PKG-li-physics-em` |
| `li-physics-quantum` | `physics.quantum` | `PKG-li-physics-quantum` |
| `li-physics-relativity` | `physics.relativity` | `PKG-li-physics-relativity` |
| `li-physics-hep` | `physics.hep` | `PKG-li-physics-hep` |

## Dependencies

- Monorepo CI template: `scripts/templates/github-repo/ci.yml`
- Push tooling: `scripts/push-official-package-repo.sh`
- Name alignment: `scripts/align-package-repo-names.py`
- Wave C gate ([algorithms plan § Wave C](../../ecosystem/algorithms-and-libraries-plan.md)): mirrors ship **with smoke CI**, not empty repos — satisfied because packages have contracts + smoke tests
- **benchmarks** sibling PR for `tooling-catalog.md` (ecosystem-first)

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A — Preflight** | Dry-run push for all 12; fix stale `li-std-*` metadata; verify `ensure-package-ci.sh` green | `./scripts/push-official-package-repo.sh <pkg> --dry-run` ×12 passes |
| **B — Human repo gate** | Create/rename org repos (see Human-only) | 12 repos exist under `li-langverse/li-physics-*` |
| **C — Mirror push** | Initial sync from monorepo | Each repo `main` has `ci.yml`; first CI run green |
| **D — Downstream registration** | `li-downstream-repos.txt` + roadmap `official-packages.md` rows | `verify-ecosystem-notify.sh` passes |
| **E — Catalog sync** | **benchmarks** PR: `tooling-catalog.md` mirror URLs + `packages_without_org_mirror` cleared for physics | Explorer digest no longer lists physics gap |
| **F — Agent-kit rollout** | `ensure-org-agent-kit.py --local-only` per mirror | No agent-kit drift on new repos |

## Implementation commands (after `plan-approved`)

```bash
# A — preflight (from lic repo root)
python3 scripts/align-package-repo-names.py --dry-run
./scripts/ensure-package-ci.sh

for pkg in li-physics-{core,rigid,runtime,particles,fluids,weather,aero,chem,em,quantum,relativity,hep}; do
  ./scripts/push-official-package-repo.sh "$pkg" --dry-run
done

# B+C — create + push (requires GH_TOKEN; human confirms org repo creation)
for pkg in li-physics-{core,rigid,runtime,particles,fluids,weather,aero,chem,em,quantum,relativity,hep}; do
  ./scripts/push-official-package-repo.sh "$pkg" --create
done

# D — register downstream (same PR as li.toml/doc touch if any)
# append li-langverse/li-physics-* to .github/li-downstream-repos.txt
./scripts/verify-ecosystem-notify.sh
```

**Batch script (optional follow-up):** add `scripts/push-physics-mirrors.sh` wrapping the loop above — not required for first publish.

## Tests / CI

| Gate | Where |
|------|-------|
| `lic check src/lib.li` | Each mirror `ci.yml` |
| `lic build li-tests/smoke/builds.li` | Each mirror `ci.yml` |
| `check-li-def-syntax.sh` | Each mirror `ci.yml` |
| Monorepo composable smokes | `li-tests/composable/import_physics_*.li` (unchanged) |
| Tier-2 benches | **benchmarks** harness — not mirror CI scope |

## Provability / gap register

| Gap | Move | Notes |
|-----|------|-------|
| **G-physics** | Partial (unchanged) | Mirror CI proves scaffold builds; domain APIs tracked in #14 |
| **G-eco-mirror** (informal) | Open → Done | When all 12 mirrors green + catalog updated |

No **G-*** row moves to Done from documentation alone.

## Rollout

1. Human labels **`plan-approved`** on #50.
2. **lic** implementation PR: metadata alignment + `li-downstream-repos.txt` + optional batch script.
3. Maintainer runs push loop with `GH_TOKEN` (or agent with org create permission).
4. **benchmarks** PR: `tooling-catalog.md` + ingest row URLs.
5. **roadmap** PR: `official-packages.md` rows (human merge).
6. Close #50 when explorer `packages_without_org_mirror` is empty for physics and all mirror CI badges green.

## Human-only

- [ ] Label **`plan-approved`** on #50 before mirror push agents run.
- [ ] Confirm org repo creation checklist ([governance § Repo creation](2026-05-16-li-ecosystem-governance.md)).
- [ ] Rename `li-langverse/physics.runtime` → `li-physics-runtime` (or archive + fresh create if rename blocked).
- [ ] Enable branch protection on `main` for each new mirror.
- [ ] Merge **roadmap** `official-packages.md` PR (agents do not self-merge governance).
- [ ] Remove **`plan-needed`** label after plan merge.

## Deferred (explicit)

- Domain API depth (#14) — units, fields, integrator hooks per subdomain
- `feat/physics-module-packages` branch merge ([PUSH_PR.md](../../physics/PUSH_PR.md))
- Reusable `package-ci` workflow adoption ([org hygiene Wave 3](https://github.com/li-langverse/li-cursor-agents/blob/main/docs/plans/2026-05-25-org-hygiene-multi-agent-plan.md)) — follow-on after first green mirrors
- lip registry publish (`lip publish`, phase 8d)
