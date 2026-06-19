# PH-8p-a tracker reconcile (#460, supersede #428)

## Summary

Reconciles master plan Phase **8p** tracker and §8p table with shipped parallel `li-tests/run_all.sh` (`LI_TEST_JOBS`, `-j N`, per-worker `LI_BUILD_DIR`). Closes stale gap filing **#428**; **8p-b** / **8p-d** remain open ([#385](https://github.com/li-langverse/lic/issues/385)).

## Agent continuation

1. **Read:** `docs/superpowers/plans/2026-05-14-li-master-plan.md` § 8p; `li-tests/run_all.sh` `run_parallel`.
2. **Run:** `./li-tests/tooling/run_all_parallel_smoke.sh`; `LI_TEST_JOBS=2 ./li-tests/run_all.sh math_syntax`.
3. **Next:** 8p-b workspace pool (`LI_WORKSPACE_JOBS`); 8p-d wall-time SLO logging.
4. **Blocked on:** ecosystem baseline `wall_s` measurement (8p-d).

## Changed

| Path | Note |
|------|------|
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | §8p layers + sub-phases + tracker + v2 backlog |
| `docs/superpowers/plans/2026-05-22-parallel-compile-ci.md` | 8p-a shipped; env defaults; agent continuation |

## Not changed

- `li-tests/run_all.sh` implementation (already on `main`).
- `provability-gaps.md` — scheduling semantics unchanged.
- 8p-b workspace pool, 8p-d wall-time SLO gates.

## Breaking / Security / Performance / Downstream

N/A — documentation reconciliation only.
