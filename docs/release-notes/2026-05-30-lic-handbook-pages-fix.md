# lic Pages — add missing site artifact

**Date:** 2026-05-30  
**Agent:** docs_maintainer (heap coord_ecosystem)

## Summary

- PR #535 merged `pages.yml` but omitted `site/index.html`; the Handbook (Pages) workflow failed on `test -f site/index.html`.
- Add `site/index.html` handbook hub so https://li-langverse.github.io/lic/ passes ecosystem-audit HEAD checks.

## Verification

- Merge to `main` → Handbook (Pages) workflow succeeds → HEAD https://li-langverse.github.io/lic/ returns 200.
- Re-run `python3 scripts/ecosystem-audit.py` in benchmarks.
- No **G-*** status changes.
