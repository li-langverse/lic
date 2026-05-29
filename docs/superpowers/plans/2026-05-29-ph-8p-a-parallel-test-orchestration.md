# PH-8p-a: Parallel test orchestration (LI_TEST_JOBS)

> **Issue:** [#428](https://github.com/li-langverse/lic/issues/428) · **Repo:** li-langverse/lic  
> **Vision:** blazingly-fast (CI throughput), provable (deterministic pass/fail unchanged) · **Learned from:** [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) § 8p, Ninja `-j` C++ build pattern, Rust `cargo test --jobs` isolation model

## Goal

Ship **8p-a** — parallel `li-tests/run_all.sh` with `LI_TEST_JOBS` / `-j N`, isolated per-worker build trees, and identical pass/fail semantics to sequential mode — so local CI and GHA wall time drops without weakening proof gates.

## Non-goals

- **8p-b** workspace pool (`#385`) — separate issue
- **8p-c** `lic --jobs` frontend parallelism — separate PR track
- **8p-d** wall-time SLO logging — follows 8p-a green
- Distributed / remote compilation, parallel Lean search inside one VC

## Dependencies

- **PH-8p** master plan row (partial)
- Existing `LI_BUILD_DIR` support in `lic build` (verify or document temp-dir copy v1)
- Human-only: none (no new repos or secrets)

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **8p-a-1** | `LI_TEST_JOBS` env + `-j N` CLI on `run_all.sh` | Default = host cores; `=1` bisect mode documented |
| **8p-a-2** | Isolated `LI_BUILD_DIR` per worker subprocess | No concurrent writes to shared `build/generated/AutoVC.lean` |
| **8p-a-3** | Aggregate pass/fail/skip footer unchanged | `LI_TEST_JOBS=8` and `=1` produce same pass/fail on Linux |
| **8p-a-4** | Docs + getting-started | `docs/guide/getting-started-tools.md` lists env vars |

## Tests / benches

- `LI_TEST_JOBS=8 ./li-tests/run_all.sh` → **196/196** pass (manifest count on `main`)
- `LI_TEST_JOBS=1 ./li-tests/run_all.sh` → identical pass/fail
- `HTTPD_SKIP_LI_ROUTING_BIN=1 ./scripts/local-ci.sh` → exit 0 (regression)
- No new tier-N bench; wall-time logged once in ecosystem baseline (8p-d follow-up)

## Provability

- **G-lean**, **G-vc**, **G-par**: **no row moves** — orchestration only; scheduling must not change what “green” means
- Update `provability-gaps.md` **only** if parallel workers introduce nondeterministic Lean races (should not happen with isolated dirs)

## Rollout

1. PR: `run_all.sh` + optional `scripts/lib/li-ui.sh` progress
2. PR: docs + `li-agent-manifest.toml` note for agents
3. Flip master plan **8p-a** checkbox when exit gate met; leave **8p** row open until 8p-b/c/d complete
4. Downstream: benchmarks `agent-preflight.sh` may export `LI_TEST_JOBS` in CI (no cron change)
