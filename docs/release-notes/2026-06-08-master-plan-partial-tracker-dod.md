# Release notes: 2026-06-08 — master plan partial tracker DoD

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Issue:** [#25](https://github.com/li-langverse/lic/issues/25)  
**PH / REQ:** PH-doc hygiene (plan sync)  
**Author:** code_implementer agent

---

## Summary (one sentence)

Added **Definition of done (closure evidence)** checklists for partial master-plan tracker rows **2e**, **2f**, **2i**, **7d**, **7e**, **H (M1 `.li`)**, and **Vision-LLM**, citing `li-tests` paths, gate scripts, and **G-*** register moves so agents cannot close trackers from narrative-only edits.

## Agent continuation (required)

1. **Read** the new § *Partial tracker rows — definition of done* in [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md) before flipping any partial checkbox.
2. **Run** `./scripts/check-doc-provability-claims.sh` after merge.
3. **Next** — implement closure per row (compiler/proof work), not doc-only checkbox flips.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Master plan | DoD subsections for 8 partial rows | `docs/superpowers/plans/2026-05-14-li-master-plan.md` |
| Cross-check | Links to `provability-gaps.md`, `proof-corpus-roadmap.md`, httpd prerequisites | Same file |

## Not changed (scope fence)

- Compiler C++ implementation — **not** changed
- `provability-gaps.md` **G-*** row statuses — **not** changed
- Phase tracker checkboxes — remain as before (partial rows still `[ ]` or **partial** narrative)

## Breaking changes

None.

## Security / Performance / Downstream

N/A — documentation-only.
