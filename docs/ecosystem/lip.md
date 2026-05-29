# Package manager (`lip`)

**Repository:** [`li-langverse/lip`](https://github.com/li-langverse/lip) · **PKG id:** `PKG-lip`

`lip` resolves, fetches, locks, and publishes Li packages. Every dependency must pass **`lic build`** (proof gate) and **`lit test --coverage`** (≥ 80% line coverage on publish/install).

## Status

| Area | Today |
|------|-------|
| Scaffold | `./scripts/li-new-package` in **lic** — same `li.toml` schema |
| `lip init` / `add` / `publish` | **Partial** — see [package manager plan](../superpowers/plans/2026-05-16-li-package-manager-lip.md) phases **8a–8e** |
| Registry | Git URLs + semver tags; central index in **lip** repo |

## Quick links

| Topic | Doc |
|-------|-----|
| Master plan tracker | [§ Phase 8](../superpowers/plans/2026-05-14-li-master-plan.md) |
| Implementation plan | [2026-05-16-li-package-manager-lip.md](../superpowers/plans/2026-05-16-li-package-manager-lip.md) |
| Package layout | [Creating packages](../guide/creating-packages.md) |
| Coverage policy | [Engineering standards](engineering-standards.md) |
| Test runner | [lit handbook](lit.md) |

## CLI (target)

```bash
lip init              # wrap li-new-package + lockfile hooks (8b)
lip add pkg@1.2.3     # resolve graph, fetch, lic build + lit on deps
lip publish           # signature + proof + coverage gate (8d)
```

Until **8b** lands, use the monorepo scaffold and path/git deps documented in [package scaffold plan](../superpowers/plans/2026-05-16-li-package-scaffold.md).

## Release notes

User-facing changes: `CHANGELOG.md` in the **lip** repo + `docs/release-notes/` entries per [engineering standards](engineering-standards.md).
