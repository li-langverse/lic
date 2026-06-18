# 8p-b/d: parallel workspace pool + local-ci wall_s logging

## Summary

`lic-workspace-build.sh` runs workspace member smokes through the shared `li_workspace_jobs` pool (honors `LI_TEST_JOBS` / `LI_WORKSPACE_JOBS`) with per-member `--build-dir` isolation. `local-ci.sh` logs `wall_s` to stdout and `benchmarks/data/latest/local-ci-wall.json` after a green run.

Closes [#385](https://github.com/li-langverse/lic/issues/385) (8p-b + 8p-d implementation slices).

## Agent continuation

1. **Read:** `scripts/lic-workspace-build.sh`, `scripts/lib/li-jobs.sh`, `scripts/local-ci.sh`, `docs/ecosystem/lic-ecosystem-baseline.md` §8p throughput.
2. **Run:** `./scripts/build.sh`; `./li-tests/tooling/ci_test_jobs_smoke.sh`; `./li-tests/tooling/workspace_build_parallel_smoke.sh`; `HTTPD_SKIP_LI_ROUTING_BIN=1 ./scripts/local-ci.sh` on devbox → fill baseline `wall_s` rows.
3. **Next:** Close master-plan **8p** checkbox when baseline SLO rows measured (≤50% vs `-j1` on 8-core).

## Changed

| Path | Evidence |
|------|----------|
| `scripts/lic-workspace-build.sh` | Parallel member builds via `li_workspace_jobs`; isolated `build/li-ws-*` trees |
| `scripts/ci.sh` | `LI_WORKSPACE_JOBS=8`; `workspace_build_parallel_smoke.sh` in 8p smokes |
| `scripts/local-ci.sh` | `wall_s` logging (native + docker paths) |
| `li-tests/tooling/workspace_build_parallel_smoke.sh` | CI/local gate for 8p-b pool |
| `docs/ecosystem/lic-ecosystem-baseline.md` | 8p-b/d checklist + local-ci wall_s row |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | Phase **8p** tracker — 8p-b shipped |

## Not changed

- Parallel MIR/LLVM frontend passes (8p-c reserved jobs only).
- Proof gates, `trusted.lean`, tier physics benches.

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| Breaking | N/A — default local `LI_TEST_JOBS=1` unchanged |
| Security | N/A |
| Performance | Workspace build wall time scales with member pool when `LI_TEST_JOBS>1` |
| Downstream | Fill baseline `wall_s` after green `local-ci.sh` on devbox |
