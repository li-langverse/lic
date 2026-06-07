# PH-8p-a: Parallel test orchestration (LI_TEST_JOBS)

> **Issue:** [#428](https://github.com/li-langverse/lic/issues/428) · **Repo:** li-langverse/lic  
> **Vision:** blazingly-fast (CI throughput), provable (deterministic pass/fail unchanged) · **North star fit:** `coord_platform` — ecosystem CI wall time without weakening proof gates  
> **Learned from:** [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) § 8p, [2026-05-25-8p-a release notes](../../release-notes/2026-05-25-8p-a-parallel-li-tests.md), GNU job-pool / Rust `cargo test --jobs` isolation model

## Goal

Close **PH-8p-a** — parallel `li-tests/run_all.sh` with `LI_TEST_JOBS` / `-j N`, isolated per-worker build trees, and identical pass/fail semantics to sequential mode — so local CI and GHA wall time drops without weakening proof gates.

## Status (2026-06-07)

| Slice | State | Evidence |
|-------|-------|----------|
| **8p-a-1** `LI_TEST_JOBS` + `-j N` | **Shipped** | `scripts/lib/li-jobs.sh`, `li-tests/run_all.sh` |
| **8p-a-2** Isolated `LI_BUILD_DIR` per worker | **Shipped** | `run_one_worker`, `build/li-test-<id>/`, `lic build --build-dir=` |
| **8p-a-3** Deterministic pass/fail footer | **Shipped** | `run_sequential` vs `run_parallel`; `parallel_run_all_smoke.sh` |
| **8p-a-4** Docs | **Partial** | Release notes; getting-started env table pending audit |
| **Plan doc on `main`** | **Open** | Prior draft PR [#430](https://github.com/li-langverse/lic/pull/430) closed unmerged |

**Implementation PRs (merged):** [#200](https://github.com/li-langverse/lic/pull/200), [#205](https://github.com/li-langverse/lic/pull/205).  
**Related (not this issue):** [#385](https://github.com/li-langverse/lic/issues/385) — **8p-b** workspace pool + **8p-d** wall-time SLO.

Issue #428 body predates merge; treat acceptance criteria below as **verification gates**, not greenfield work.

## Non-goals

- **8p-b** workspace pool — [#385](https://github.com/li-langverse/lic/issues/385)
- **8p-c** `lic --jobs` frontend parallelism — [#525](https://github.com/li-langverse/lic/issues/525) / PR [#908](https://github.com/li-langverse/lic/pull/908)
- **8p-d** wall-time SLO logging — [#385](https://github.com/li-langverse/lic/issues/385)
- Distributed / remote compilation; parallel Lean search inside one VC

## Architecture (as-built)

```
run_all.sh
  ├─ li_test_jobs()          ← LI_TEST_JOBS env; default 1 local, host cores when CI=true
  ├─ collect_manifest_rows()
  ├─ TEST_JOBS ≤ 1 → run_sequential()
  └─ TEST_JOBS > 1 → run_parallel()
        └─ run_one_worker(id) → WORKER_BUILD_DIR=build/li-test-<id>/
              └─ lic build --build-dir=…  (AutoVC under worker tree)
```

**Race guard:** No concurrent writes to shared `build/generated/AutoVC.lean`; each worker owns `build/li-test-<id>/generated/`.

## Sub-phases & exit gates

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **8p-a-1** | `LI_TEST_JOBS` env + `-j N` CLI | Default = host cores when `CI=true`, else **1**; `LI_TEST_JOBS=1` bisect documented |
| **8p-a-2** | Isolated build dir per worker | `parallel_run_all_smoke.sh` green; no shared AutoVC stomp |
| **8p-a-3** | Aggregate pass/fail/skip footer unchanged | `LI_TEST_JOBS=8` and `=1` same pass/fail on Linux CI |
| **8p-a-4** | Operator docs | `docs/guide/getting-started-tools.md` lists `LI_TEST_JOBS` (audit in impl PR if missing) |

## Tests / benches

| Check | Command | Target |
|-------|---------|--------|
| Parallel manifest | `LI_TEST_JOBS=8 ./li-tests/run_all.sh` | Full manifest pass, exit 0 |
| Determinism | `LI_TEST_JOBS=1 ./li-tests/run_all.sh` | Identical pass/fail vs parallel |
| Smoke | `./li-tests/tooling/parallel_run_all_smoke.sh` | exit 0 |
| CI regression | `HTTPD_SKIP_LI_ROUTING_BIN=1 ./scripts/local-ci.sh` | exit 0 |
| Wall time | — | **8p-d** ([#385](https://github.com/li-langverse/lic/issues/385)); no tier-N bench |

## PH / REQ / G-* mapping

| ID | Role |
|----|------|
| **PH-8p-a** | Parallel `run_all.sh` orchestration (this plan) |
| **PH-8p** | Parent row — stays `[ ]` until 8p-b/c/d complete |
| **REQ-coord-ci** | CI throughput; proof gate unchanged |
| **G-lean / G-vc / G-par** | **No row moves** — scheduling only |

Update [provability-gaps.md](../../verification/provability-gaps.md) **only** if parallel workers introduce nondeterministic Lean races (should not occur with isolated dirs).

## Rollout & issue closure (#428)

1. **This PR:** merge plan doc only (no product code).
2. Maintainer adds label **`plan-approved`** on #428; remove **`plan-needed`**.
3. **Verification agent / human:** run exit-gate table above on Linux CI; comment results on #428.
4. **Close #428** when gates green — master plan tracker already notes 8p-a partial ([#200](https://github.com/li-langverse/lic/pull/200)).
5. Track remaining **8p** work in [#385](https://github.com/li-langverse/lic/issues/385) (8p-b/d) and 8p-c PRs.

## Agent continuation (post plan-approved)

If any gate fails after merge:

1. Read `scripts/lib/li-jobs.sh`, `li-tests/run_all.sh`, `compiler/lic/main.cpp` (`repo_build_path`).
2. Fix gap in isolated PR; do **not** weaken proof outcomes.
3. Re-run parallel + sequential manifest; attach log to #428.

If all gates pass: close #428; no further 8p-a implementation PRs unless regression.
