# lip — package manager

<!-- DOC-ecosystem-lip -->

**Repository:** [`li-langverse/lip`](https://github.com/li-langverse/lip) · **Package id:** `PKG-lip`

**lip** resolves, locks, fetches, and publishes Li packages (`li.toml` / `li.lock`). It shares the org repo with **lit** (test runner); see [lit](lit.md).

## Status

| Area | Status |
|------|--------|
| Bootstrap / CI | In place — `scripts/bootstrap_lip.sh`, org `ci.yml` |
| Resolver + lockfile | **Partial** — see [package manager plan](../superpowers/plans/2026-05-16-li-package-manager-lip.md) |
| Registry publish | **Partial** — ed25519 + `lic build` gate per [engineering standards](engineering-standards.md) |
| Proof surface | **G-*** rows in [provability gaps](../verification/provability-gaps.md) apply to published packages |

## Quick start

```bash
cd ../li-language && ./scripts/build.sh   # build lic
cd ../lip
export LIC=../li-language/build/compiler/lic/lic
./scripts/bootstrap_lip.sh
./build/lip --version
```

## In-repo docs (canonical detail until this page is expanded)

| Doc | Topic |
|-----|--------|
| [lip/docs/lip.md](https://github.com/li-langverse/lip/blob/main/docs/lip.md) | CLI reference |
| [lip/docs/registry.md](https://github.com/li-langverse/lip/blob/main/docs/registry.md) | Index + publish CI |
| [lip/docs/handbook.md](https://github.com/li-langverse/lip/blob/main/docs/handbook.md) | Cross-links |

## Vision & plan cross-links

| Doc | Role |
|-----|------|
| [Master plan — PH-8](https://github.com/li-langverse/lic/blob/main/docs/superpowers/plans/2026-05-14-li-master-plan.md) | Ecosystem repo policy |
| [Package manager plan](../superpowers/plans/2026-05-16-li-package-manager-lip.md) | Normative lip/lit design |
| [Provability gaps](../verification/provability-gaps.md) | Honest **G-*** status |
| [Official packages](official-packages.md) | Org table |
| [Benchmarks dashboard](https://li-langverse.github.io/benchmarks/) | Perf after compiler changes |

## Release notes

Per-merge notes live in the **lip** repo under `docs/release-notes/` — policy: [roadmap release-notes](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/release-notes.md).
