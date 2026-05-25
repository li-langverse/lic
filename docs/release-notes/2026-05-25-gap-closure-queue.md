# Gap closure queue (Phase 2a audit)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** `chore/gap-closure-queue`  
**PH / REQ:** Doc — verification honesty  
**Author:** agent

---

## Summary (one sentence)

Adds `docs/verification/GAP_CLOSURE_QUEUE.md` — prioritized open gaps from plan-completion audit and **G-*** register, excluding gaps already claimed by open PRs.

## Agent continuation (required)

1. **Read:** `docs/verification/GAP_CLOSURE_QUEUE.md`, `docs/verification/provability-gaps.md`, `../benchmarks/data/latest/plan-completion-audit.json`.
2. **Run:** `python3 ../benchmarks/scripts/plan-completion-audit.py` with `LIC_ROOT=$PWD`; `gh pr list --repo li-langverse/lic --state open`.
3. **Then:** Pick rank-1 **P0** row not covered by an open PR; implement on a feature branch; update provability-gaps in the same PR as code.
4. **Blocked on:** human merge of this doc-only PR; do not self-merge.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `docs/verification/GAP_CLOSURE_QUEUE.md` | Prioritized queue P0–P2, vertical map, open-PR exclusion table | Phase 2a read-only audit 2026-05-25 |

## Not changed

- Compiler, `li-tests`, Lean, studio packages, benchmarks harness — **no code**.
- [provability-gaps.md](../verification/provability-gaps.md) status rows — **unchanged** (queue is triage only).
- Open PR branches (#251–#253, #183, etc.) — **not** modified.

## Breaking / Security / Performance / Downstream

| Section | Status |
|---------|--------|
| Breaking | N/A — documentation only |
| Security | N/A |
| Performance | N/A |
| Downstream | Agents should read queue before starting duplicate gap work |
