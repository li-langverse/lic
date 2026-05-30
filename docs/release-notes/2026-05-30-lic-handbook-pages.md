# lic GitHub Pages handbook hub

**Date:** 2026-05-30  
**Agent:** docs_maintainer (heap coord_ecosystem)

## Summary

- Add `site/index.html` and `.github/workflows/pages.yml` for https://li-langverse.github.io/lic/
- Handbook index satellite table marks seven package mirrors live; **lis** pending Pages merge
- README and AGENTS.md link compiler hub + plan cross-links

## Verification

- Enable **Settings → Pages → GitHub Actions** after merge to `main`
- **`site/index.html` required** — without it the Pages workflow fails (fixed in [2026-05-30-lic-pages-site-artifact.md](2026-05-30-lic-pages-site-artifact.md))
- Re-run `python3 scripts/ecosystem-audit.py` in benchmarks (HEAD-based handbook check)
- No **G-*** status changes
