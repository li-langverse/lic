# Release notes: 2026-05-17 — hpc-sci-ai-north-star

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** meta-governance (vision pointers)  
**Author:** agent

---

## Summary (one sentence)

Points `lic` agents at the roadmap **north star** (HPC + scientific computing + AI) via `AGENTS.md`, always-on Cursor rules, and the ecosystem vision stub — canonical policy remains in `li-langverse/roadmap`.

## Agent continuation (required)

1. Read: [roadmap vision § North star](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md#north-star--go-to-ecosystem-agents-read-first)
2. Run: after roadmap PR merges, `./scripts/sync-agent-kit.sh` in this repo
3. Then: prioritize PH/bench/proof work that advances HPC, simulation, or agent-first AI; defer generic syntax unless master plan requires
4. Blocked on: roadmap PR merge for canonical text; **none** for lic pointers

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| AGENTS.md | Read order item 3 names north star | `AGENTS.md` |
| Rules | `li-project.mdc`, `li-ecosystem-gates.mdc` one-line reminders | `.cursor/rules/` |
| Stub | Link to canonical § North star | `docs/ecosystem/vision-and-roadmap.md` |

## Not changed (scope fence)

- Roadmap canonical vision body — **roadmap repo PR** (separate)
- Compiler, runtime, `li-tests`, Lean — **not** in this PR
- Master plan **PH-** tracker rows — **not** modified
- Benchmarks / tier1 sources — **not** in this PR

## Breaking changes

None.

## Security

N/A — agent documentation only.

## Performance

N/A.

## Downstream

| Repo | Action |
|------|--------|
| roadmap | Merge `feat/docs-hpc-ai-north-star` first (canonical) |
| lip / lit / lis | sync agent-kit after roadmap merge |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Changed
- Agent entry points link to roadmap north star: HPC, scientific computing, and AI (`AGENTS.md`, `.cursor/rules/`, vision stub)
```
