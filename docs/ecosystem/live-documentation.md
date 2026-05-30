# Live documentation map

Org repos publish handbooks via **GitHub Pages** or the **li-language** mkdocs site. Agents use this table with [plan cross-links](plan-cross-links.md) and [ecosystem-audit](https://github.com/li-langverse/benchmarks/blob/main/scripts/ecosystem-audit.py) (`repos_without_live_docs`, `live_docs_down`).

## Canonical live sites

| Site | URL | Source repo | Notes |
|------|-----|-------------|-------|
| **Language handbook** | https://li-langverse.github.io/li-language/ | [lic](https://github.com/li-langverse/lic) (`mkdocs.yml`) | Master plan, verification, ecosystem stubs |
| **Benchmarks dashboard** | https://li-langverse.github.io/benchmarks/ | [benchmarks](https://github.com/li-langverse/benchmarks) | Tier posture; measurements ≠ proof |
| **Development overview** | https://li-langverse.github.io/roadmap/development-overview/ | [roadmap](https://github.com/li-langverse/roadmap) | Governance vision (human merge) |

## Satellite package handbooks (Pages on repo)

Each row ships `docs/handbook.md` + `site/index.html` + `.github/workflows/pages.yml`. Audit clears after **merge to `main`** and Pages deploy.

| Repo | Expected Pages URL | Handbook | Open PR (if any) |
|------|-------------------|----------|------------------|
| [lip](https://github.com/li-langverse/lip) | https://li-langverse.github.io/lip/ | [handbook.md](https://github.com/li-langverse/lip/blob/main/docs/handbook.md) | [#31](https://github.com/li-langverse/lip/pull/31) |
| [lit](https://github.com/li-langverse/lit) | https://li-langverse.github.io/lit/ | [handbook.md](https://github.com/li-langverse/lit/blob/main/docs/handbook.md) | [#17](https://github.com/li-langverse/lit/pull/17) |
| [lis](https://github.com/li-langverse/lis) | https://li-langverse.github.io/lis/ | [handbook.md](https://github.com/li-langverse/lis/blob/main/docs/handbook.md) | pending |
| [li-httpd](https://github.com/li-langverse/li-httpd) | https://li-langverse.github.io/li-httpd/ | in-repo | [#16](https://github.com/li-langverse/li-httpd/pull/16) ✓ CI |
| [li-net](https://github.com/li-langverse/li-net) | https://li-langverse.github.io/li-net/ | in-repo | [#14](https://github.com/li-langverse/li-net/pull/14) ✓ CI |
| [li-std-core](https://github.com/li-langverse/li-std-core) | https://li-langverse.github.io/li-std-core/ | in-repo | [#10](https://github.com/li-langverse/li-std-core/pull/10) ✓ CI |
| [li-std-math](https://github.com/li-langverse/li-std-math) | https://li-langverse.github.io/li-std-math/ | in-repo | [#11](https://github.com/li-langverse/li-std-math/pull/11) ✓ CI |
| [li-demo](https://github.com/li-langverse/li-demo) | https://li-langverse.github.io/li-demo/ | in-repo | [#18](https://github.com/li-langverse/li-demo/pull/18) (CI red) |
| [roadmap](https://github.com/li-langverse/roadmap) | https://li-langverse.github.io/roadmap/ | dev overview | [#39](https://github.com/li-langverse/roadmap/pull/39) ✓ CI |

**lic** itself is listed in audit until satellite Pages land; primary reader path remains **li-language** mkdocs above.

## Cross-links (required in every handbook)

| Doc | Role |
|-----|------|
| [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | PH order, repo policy |
| [Plan cross-links](plan-cross-links.md) | **G-*** ↔ phase plan index |
| [Provability gaps](../verification/provability-gaps.md) | Honest proof status |
| [Engineering standards](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md) | Publish gates |
| [Release notes policy](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/release-notes.md) | User-facing changelog |

Benchmark rows cite [dashboard](https://li-langverse.github.io/benchmarks/) only as **measurements** — mark **G-*** Partial/Done with cited evidence, not bench green alone.
