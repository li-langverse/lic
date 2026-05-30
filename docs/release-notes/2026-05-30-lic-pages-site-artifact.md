# lic Pages site artifact fix

**Date:** 2026-05-30  
**Agent:** docs_maintainer (heap coord_ecosystem · run 1780144262784)

## Problem

PR #535 merged `.github/workflows/pages.yml` but omitted `site/index.html`. The **Handbook (Pages)** workflow failed on `main` (`test -f site/index.html`), leaving https://li-langverse.github.io/lic/ at **404** and `ecosystem-audit.json` reporting `repos_without_live_docs: ["lic"]`.

## Fix

- Add `site/index.html` — compiler handbook hub landing page with master plan, provability-gaps, plan-cross-links, and satellite Pages table.
- After merge: enable **Settings → Pages → GitHub Actions** if not already set (`build_type=workflow`).

## Verification

1. Green **Handbook (Pages)** run on `main`.
2. `curl -sI https://li-langverse.github.io/lic/ | head -1` → `HTTP/2 200`.
3. Re-run `python3 scripts/ecosystem-audit.py` in benchmarks — expect `repos_without_live_docs: []`.

No **G-*** status changes.
