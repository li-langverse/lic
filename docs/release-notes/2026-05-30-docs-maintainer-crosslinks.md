# Docs maintainer — plan cross-links and live handbook map

**Audience:** agents, ecosystem maintainers

## Summary

- Added [plan-cross-links.md](../ecosystem/plan-cross-links.md) — master plan ↔ provability-gaps ↔ phase plans (mirrors benchmarks ecosystem map, lives in `lic`).
- Added [live-handbook-sites.md](../ecosystem/live-handbook-sites.md) — GitHub Pages URLs for `li-language`, satellite repos, and audit recovery steps.
- Linked both from master plan **Doc** phase, site index, and provability gap register.
- Removed duplicate proof-db appendix block in `provability-gaps.md`.

## Deferred (separate PRs)

- **`benchmarks`:** HEAD-probe `ecosystem-audit.py` instead of static missing-repo list.
- **Satellite repos:** enable Pages on `main` where `site/index.html` exists but URL still 404s.
- **`li-language` / #403:** strict mkdocs build + full 12-tab deploy.

## Test plan

- [ ] Links resolve on GitHub (`docs/ecosystem/*.md`)
- [ ] After Pages deploy: `python3 scripts/ecosystem-audit.py` in benchmarks (expect shrinking `repos_without_live_docs`)
