# Satellite handbook Pages (org packages)

Official mirrors (`lip`, `lit`, `lis`, `li-net`, `li-httpd`, `li-std-*`, `li-demo`, `roadmap`) ship a **minimal** GitHub Pages site so ecosystem-audit can resolve a live handbook URL per repo.

## Template (copy per repo)

| Artifact | Purpose |
|----------|---------|
| `site/index.html` | Static landing with nav to master plan, provability gaps, benchmarks, language handbook |
| `.github/workflows/pages.yml` | `upload-pages-artifact` on `main` (no mkdocs required) |
| `docs/handbook.md` | In-repo mirror of cross-links (works before Pages deploy) |
| `README.md` | **Live handbook:** `https://li-langverse.github.io/<repo>/` |

Reference implementation: [lip `site/index.html`](https://github.com/li-langverse/lip/blob/main/site/index.html).

Required nav links on every satellite page:

- [Master plan](https://github.com/li-langverse/lic/blob/main/docs/superpowers/plans/2026-05-14-li-master-plan.md)
- [Provability gaps (G-*)](https://github.com/li-langverse/lic/blob/main/docs/verification/provability-gaps.md)
- [Plan cross-links](https://github.com/li-langverse/lic/blob/main/docs/ecosystem/plan-cross-links.md)
- [Benchmarks dashboard](https://li-langverse.github.io/benchmarks/)
- [Language handbook](https://li-langverse.github.io/li-language/)

Footer honesty line (required):

> Benchmark rows are measurements, not proof certificates. Mark **G-*** Partial/Done only with cited evidence.

## Deploy checklist (human)

1. Merge handbook PR on `main`.
2. Repo **Settings → Pages → Build and deployment: GitHub Actions**.
3. Re-run `python3 scripts/ecosystem-audit.py` — repo drops from `repos_without_live_docs` when `HEAD` on `https://li-langverse.github.io/<repo>/` returns 2xx.

Primary language docs remain on **li-language** mkdocs; satellites are **traceability stubs**, not full handbooks.
