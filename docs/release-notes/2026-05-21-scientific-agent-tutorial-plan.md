# Release notes: 2026-05-21 — scientific-agent-tutorial-plan

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/scientific-agent-tutorial-plan-e8f9`  
**PH / REQ:** Docs tutorial plan; supports PH-5b/PH-7e onboarding and ecosystem gates  
**Author:** agent

---

## Summary (one sentence)

Added a writing plan for a first Li tutorial that combines new-user onboarding, agent workflow, and scientific/HPC proof-and-performance discipline.

## Agent continuation (required)

1. Read: `docs/superpowers/plans/2026-05-21-scientific-agent-tutorial.md`, `docs/guide/hello-world.md`, `docs/guide/getting-started-tools.md`, and `docs/guide/fast-math-and-parallelism.md`.
2. Run: the placeholder and unlabeled-fence checks embedded in `docs/superpowers/plans/2026-05-21-scientific-agent-tutorial.md` after creating the tutorial page.
3. Then: implement `docs/guide/build-and-verify-scientific-program.md`, add it to `mkdocs.yml`, and run the tutorial's shown `lic` commands before committing.
4. Blocked on: none.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Tutorial planning | Added `docs/superpowers/plans/2026-05-21-scientific-agent-tutorial.md` with audience, tone, code-block style, outline, tasks, and verification steps | Markdown placeholder/fence checks pass |
| Release notes | Added this handoff and updated `CHANGELOG.md` under `## [Unreleased]` | Release-note policy sections are present |

## Not changed (scope fence)

- No tutorial page was implemented in `docs/guide/`.
- No `mkdocs.yml` navigation change was made.
- No compiler, proof, benchmark, package, or agent-kit behavior changed.

## Breaking changes

None — documentation planning only.

## Security

N/A — no attack surface, trusted base, parser, runtime, or policy behavior changed.

## Performance

N/A — no code or benchmark behavior changed; the plan instructs the future tutorial to avoid unsupported performance claims.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis / packages | N/A — no toolchain or package behavior changed |

## CHANGELOG entry (paste into Unreleased)

- **Scientific tutorial writing plan** — first-user + agent + HPC tutorial outline, tone guidance, and syntax-highlighted code-block rules; see `docs/superpowers/plans/2026-05-21-scientific-agent-tutorial.md`.
