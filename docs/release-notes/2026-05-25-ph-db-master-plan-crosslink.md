# Release notes: 2026-05-25 — ph-db-master-plan-crosslink

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (fill on open)  
**PH / REQ:** PH-DB-0 … PH-DB-10, PH-8d-v2 → PH-DB-4  
**Author:** agent

---

## Summary (one sentence)

Adds **PH-DB** to the lic master plan phase map and appendix cross-linking roadmap `lidb` proposals, including **`PH-8d-v2` → `PH-DB-4`** dependency.

## Agent continuation (required)

1. Read: `docs/superpowers/plans/ph-db-lidb-platform.md`; roadmap [vision-and-roadmap § PH-DB](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md#li-data-platform-ph-db-0--ph-db-10)
2. Run: N/A (docs-only)
3. Then: human creates `li-langverse/lidb` for **PH-DB-1**; implement engine in `lidb` repo after merge
4. Blocked on: human repo creation for **PH-DB-1**; **PH-8d-v2** until **PH-DB-4** exit gate

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Master plan | **PH-DB** row in phase map; Future org repos `lidb`; v2 backlog note | `docs/superpowers/plans/2026-05-14-li-master-plan.md` |
| Appendix | PH-DB-0..10 ids + **PH-8d-v2 → PH-DB-4**; roadmap proposal URLs | `docs/superpowers/plans/ph-db-lidb-platform.md` |

## Not changed (scope fence)

- **`lidb` runtime** — no engine, WAL, or SQL implementation in **`lic`**
- **Roadmap repo** — canonical PH table already in `vision-and-roadmap.md`; this PR is lic cross-link only
- **`lip` / `lit` / compiler** — no registry v2 API or CI gate changes
- **PH-8d v1** — local registry publish unchanged

## Breaking changes

None — documentation only.

## Security

N/A — no code paths; future PH-DB-2 security harness referenced in roadmap ADR only.

## Performance

N/A — bench evidence path is `tier_db_registry` in benchmarks repo (not run here).

## Downstream

| Repo | Action |
|------|--------|
| roadmap | N/A — already has PH-DB table |
| lip | Defer **PH-8d-v2** until **PH-DB-4** |
| lidb (proposed) | Scaffold after human creates repo |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-DB master plan cross-link:** phase map row + `ph-db-lidb-platform.md` appendix; **PH-8d-v2 → PH-DB-4** — [2026-05-25-ph-db-master-plan-crosslink.md](docs/release-notes/2026-05-25-ph-db-master-plan-crosslink.md).
```
