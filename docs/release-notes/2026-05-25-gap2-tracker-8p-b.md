# Release notes: 2026-05-25 — gap2 tracker 8p-b workspace pool

**Status:** Ready for review | **Repo:** li-langverse/lic | **PH:** Phase **8p-b**

## Summary

Parallel job pool for `lic-workspace-build.sh` with per-member `--build-dir` (`LI_WORKSPACE_JOBS` / `-j`) plus CI smoke.

## Agent continuation

1. Read master plan § 8p and `scripts/lib/li-jobs.sh`.
2. Run `./scripts/build.sh && ./li-tests/tooling/workspace_build_parallel_smoke.sh`.
3. Next: 8p-c MIR `--jobs`; 8p-d wall-time SLO.

## Changed

| Area | What |
|------|------|
| 8p-b | `lic-workspace-build.sh`, `workspace_build_parallel_smoke.sh`, `scripts/ci.sh` |
| Tracker | Master plan **8p** partial row |

## Not changed

2i/7d/7e/Vision code (PR #262 covers 2i); `provability-gaps.md`; 8p-c MIR jobs.

## Breaking / Security / Performance

None / N/A / `LI_WORKSPACE_JOBS>1` optional speedup; default 1 locally.
