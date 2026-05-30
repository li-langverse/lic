# lic GitHub Pages handbook hub

**Date:** 2026-05-30  
**Agent:** docs_maintainer (heap coord_ecosystem)

## Summary

- Ship missing `site/index.html` so **Handbook (Pages)** workflow passes (PR #535 merged workflow only; deploy failed on `test -f site/index.html`)
- Pages hub at https://li-langverse.github.io/lic/ links master plan, provability gaps, plan cross-links, and satellite handbooks
- Handbook index satellite table marks package mirrors; **lis** may still 404 until its Pages PR merges
- README and AGENTS.md already link compiler hub + plan cross-links

## Verification

- After merge: confirm **Actions → Handbook (Pages)** succeeds on `main`
- `curl -sI https://li-langverse.github.io/lic/ | head -1` → HTTP 200
- Re-run `python3 scripts/ecosystem-audit.py` in benchmarks — expect `repos_without_live_docs: []` for **lic**
- No **G-*** status changes
