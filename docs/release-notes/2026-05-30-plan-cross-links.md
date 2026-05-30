# Plan cross-links and provability-gaps dedup

**Audience:** contributors, agents

## Summary

- Added [plan-cross-links.md](../ecosystem/plan-cross-links.md) — master plan ↔ **G-*** ↔ phase plan index for mkdocs Ecosystem nav.
- Linked from [provability-gaps.md](../verification/provability-gaps.md), [master plan Doc §](../superpowers/plans/2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting), and home doc map.
- Removed duplicate **Proof-db discrepancy appendix** block in provability-gaps.
- Extended phase plan index (httpd, **PH-8p**, governance, OOP) and satellite Pages deploy status table.

**Swarm:** run `1780111965960` · agent `docs_maintainer`

## Test plan

- [ ] `./scripts/build-docs.sh --strict` (or Docs CI on PR)
- [ ] Ecosystem → Plan cross-links renders in mkdocs nav
