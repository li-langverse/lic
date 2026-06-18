# Plan tracker: PH-8p-a parallel run_all shipped (tracker reconcile)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** **PH-8p-a** (parallel test orchestration; master plan tracker)

---

## Summary

Reconciles master plan §8p and phase tracker with tree evidence: parallel `li-tests/run_all.sh` (`LI_TEST_JOBS`, `-j N`, isolated `--build-dir` per worker) shipped in [#186](https://github.com/li-langverse/lic/pull/186) / [#200](https://github.com/li-langverse/lic/pull/200). Supersedes stale filing [#428](https://github.com/li-langverse/lic/issues/428). Phase **8p** checkbox stays open until **8p-b** workspace pool and **8p-d** wall-time SLO ([#385](https://github.com/li-langverse/lic/issues/385)).

## Agent continuation

1. Read: `docs/superpowers/plans/2026-05-22-parallel-compile-ci.md` § 8p-b–d.
2. Run: `./scripts/build.sh && ./li-tests/tooling/run_all_parallel_smoke.sh && ./li-tests/tooling/ci_test_jobs_smoke.sh`.
3. Then: 8p-b `LI_WORKSPACE_JOBS` pool on `lic-workspace-build.sh`; 8p-d baseline wall-time row.

## Changed

| Area | What | Evidence |
|------|------|----------|
| Master plan §8p | `run_all.sh` row → **Done (8p-a)** | `docs/superpowers/plans/2026-05-14-li-master-plan.md` |
| Phase tracker | 8p-a **shipped**; 8p-b/d **open** | same file L470 |
| 8p sub-plan | 8p-a marked shipped; env table updated | `docs/superpowers/plans/2026-05-22-parallel-compile-ci.md` |

## Not changed

- `li-tests/run_all.sh` — implementation already on main.
- `provability-gaps.md` — scheduling semantics unchanged.
- 8p-b workspace pool, 8p-d SLO gates.

## Breaking changes

None.

## Security

N/A — documentation-only tracker reconcile.

## Performance

No code change; documents existing parallel orchestration.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis | N/A |

## CHANGELOG entry

```markdown
### Changed
- **PH-8p-a:** master plan §8p + phase tracker reflect shipped parallel `run_all.sh` — closes tracker gap [#460](https://github.com/li-langverse/lic/issues/460); supersedes [#428](https://github.com/li-langverse/lic/issues/428).
```
