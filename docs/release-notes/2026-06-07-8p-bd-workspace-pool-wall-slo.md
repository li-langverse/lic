# 8p-b/d: parallel workspace pool + local-ci wall_s logging

## Summary

`lic-workspace-build.sh` runs workspace member smokes through the shared `li_workspace_jobs` pool (honors `LI_TEST_JOBS` / `LI_WORKSPACE_JOBS`) with isolated `--build-dir` trees per worker. `local-ci.sh` logs `wall_s` on completion for baseline capture.

## Agent continuation

1. **Read:** `scripts/lic-workspace-build.sh`, `scripts/lib/li-jobs.sh`, `docs/superpowers/plans/2026-05-22-parallel-compile-ci.md` §8p-b/d.
2. **Run:** `./scripts/build.sh`; `./li-tests/tooling/ci_test_jobs_smoke.sh`; `./li-tests/tooling/workspace_build_parallel_smoke.sh`.
3. **Measure:** `HTTPD_SKIP_LI_ROUTING_BIN=1 ./scripts/local-ci.sh` on an 8-core devbox; fill `docs/ecosystem/lic-ecosystem-baseline.md` `wall_s` rows.
4. **Close:** master-plan Phase **8p** tracker when exit gates pass.

## Changed

| Path | Evidence |
|------|----------|
| `scripts/lic-workspace-build.sh` | `li_workspace_jobs` pool + per-member `--build-dir` |
| `scripts/local-ci.sh` | `local-ci: wall_s=…` on native/docker exit |
| `li-tests/tooling/workspace_build_parallel_smoke.sh` | CI smoke for 8p-b pool |
| `scripts/ci.sh` | 8p parallel smokes phase includes workspace smoke |
| `docs/ecosystem/lic-ecosystem-baseline.md` | 8p-b shipped; wall-time checklist |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | Phase **8p** tracker — 8p-b/d shipped |

## Not changed

- Parallel MIR/LLVM frontend passes (8p-c reserved job count only)
- Proof gates, `trusted.lean`, tier physics benches

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A — default local `LI_TEST_JOBS=1` keeps sequential workspace builds |
| **Security** | N/A |
| **Performance** | Workspace wall time scales ~∝ members/cores when `LI_TEST_JOBS>1` |
| **Downstream** | Closes [#385](https://github.com/li-langverse/lic/issues/385) |
