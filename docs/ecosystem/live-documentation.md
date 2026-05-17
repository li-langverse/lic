# Live documentation (lic)

<!-- DOC-ecosystem-live-docs -->

**Published handbook (MkDocs Material):** https://li-langverse.github.io/lic/

Source: `mkdocs.yml` + `docs/` in this repo. CI builds on every PR (`docs-build` in `.github/workflows/ci.yml`); GitHub Pages deploys on push to `main` (`.github/workflows/docs.yml`).

## In-repo entry points

| Topic | Path |
|-------|------|
| Master plan (PH tracker) | [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md) |
| Provability gaps (**G-***) | [provability-gaps.md](../verification/provability-gaps.md) |
| Phase plans | [superpowers/plans/](../superpowers/plans/) |
| Ecosystem vision (canonical) | [roadmap: vision-and-roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| Benchmark dashboard | [benchmarks handbook](https://github.com/li-langverse/benchmarks/blob/main/docs/handbook/README.md) |

## Local preview

```bash
./scripts/build-docs.sh
python3 -m http.server -d site 8000
```

CI uses non-strict build until doc link warnings are cleared (`mkdocs build --strict` currently reports ~65 warnings).

## Legacy URL

`https://li-langverse.github.io/li-language/` — archive **`li-language`** repo; use **`lic`** Pages URL above.
