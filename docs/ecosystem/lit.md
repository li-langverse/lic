# Test runner and coverage (`lit`)

**Repository:** [`li-langverse/lit`](https://github.com/li-langverse/lit) · **PKG id:** `PKG-lit`

`lit` discovers tests, aggregates line coverage, and enforces the **≥ 80%** publish/install gate orchestrated by **lip**.

## Status

| Area | Today |
|------|-------|
| In-monorepo tests | `./li-tests/run_all.sh` — compiler conformance (not `lit` CLI yet) |
| `lit test --coverage` | **Partial** — see [package manager plan](../superpowers/plans/2026-05-16-li-package-manager-lip.md) |
| Coverage on `std/` in **lic** | **100%** line target (in-tree; not `lip publish` default) |

## Quick links

| Topic | Doc |
|-------|-----|
| Master plan tracker | [§ Phase 8](../superpowers/plans/2026-05-14-li-master-plan.md) |
| Package manager integration | [lip handbook](lip.md) |
| All compiler suites | [Testing overview](../testing/overview.md) |
| Coverage tiers | [Engineering standards](engineering-standards.md) |

## CLI (target)

```bash
lit test                  # discover + run package tests
lit test --coverage       # fail if line coverage < 80% (third-party publish)
```

## Release notes

User-facing changes: `CHANGELOG.md` in the **lit** repo + `docs/release-notes/` entries per [engineering standards](engineering-standards.md).
