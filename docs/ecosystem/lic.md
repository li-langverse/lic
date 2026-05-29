# Compiler monorepo (`lic`)

**Repository:** [`li-langverse/lic`](https://github.com/li-langverse/lic) · **PKG id:** `PKG-lic`

The **lic** tree hosts the `lic` CLI, C++ compiler, `li-tests/`, semantics (`docs/semantics/`), runtime, stdlib packages under `packages/`, and the published handbook (this site).

## Live documentation

| Surface | URL |
|---------|-----|
| Handbook (MkDocs) | [li-langverse.github.io/li-language](https://li-langverse.github.io/li-language/) |
| Master plan | [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md) |
| Provability gaps | [provability-gaps.md](../verification/provability-gaps.md) |
| Benchmarks | [li-langverse.github.io/benchmarks](https://li-langverse.github.io/benchmarks/) |

Docs deploy from **lic** `main` via [`.github/workflows/docs.yml`](https://github.com/li-langverse/lic/blob/main/.github/workflows/docs.yml) to the **li-language** GitHub Pages site.

## Build

```bash
./scripts/build.sh
./build/compiler/lic/lic build hello.li -o hello
./li-tests/run_all.sh
```

## Agent onboarding

- [AGENTS.md](https://github.com/li-langverse/lic/blob/main/AGENTS.md) — repo rules for Cursor agents
- [Engineering standards](engineering-standards.md) — proof, CVE, bench gates
- [Phase plans index](phase-plans-index.md) — master plan ↔ phase files ↔ **G-*** gaps

## Release notes

Compiler and handbook changes: root `CHANGELOG.md` + `docs/release-notes/` (see [documentation style](../contributing/documentation.md)).
