# Documentation site

<!-- DOC-ecosystem-docs-site -->

The published Li handbook is built from **[`li-langverse/lic-docs`](https://github.com/li-langverse/lic-docs)** — not the compiler monorepo (`lic`) and not the deprecated **`li-language`** archive.

| Surface | URL |
|---------|-----|
| **Primary site** | https://docs.lilangverse.xyz/ |
| **GitHub Pages mirror** | https://li-langverse.github.io/lic-docs/ |
| **Source repo** | https://github.com/li-langverse/lic-docs |
| **Build entry** | `lic-docs/mkdocs.yml` (`repo_url: https://github.com/li-langverse/lic-docs`) |

## Local build

From a sibling checkout:

```bash
git clone https://github.com/li-langverse/lic-docs ../lic-docs
./scripts/build-docs.sh --strict
```

Or set `LI_DOCS_ROOT=/path/to/lic-docs` when `lic-docs` lives elsewhere.

## Governance cross-link

Compiler and package policy docs in **`lic`** may stub or mirror content; canonical ecosystem governance lives in [`li-langverse/roadmap`](https://github.com/li-langverse/roadmap). See [governance.md](governance.md).
