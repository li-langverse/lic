# PH-8p-a: close stale #428 — parallel run_all tracker reconcile

> **Issue:** [#460](https://github.com/li-langverse/lic/issues/460) · **Supersedes:** [#428](https://github.com/li-langverse/lic/issues/428)  
> **Repo:** li-langverse/lic  
> **Vision:** **Fast** (CI throughput after proof), **Provable** (deterministic pass/fail unchanged)  
> **North star fit:** `coord_platform` / ecosystem CI — **PH-8p-a**, **PH-8p** (partial until 8p-b/d)  
> **Learned from:** [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), [2026-05-25-8p-a-parallel-li-tests.md](../../release-notes/2026-05-25-8p-a-parallel-li-tests.md), [2026-05-25-plan-tracker-8p-vision-llm.md](../../release-notes/2026-05-25-plan-tracker-8p-vision-llm.md), [2026-05-29-ph-8p-a-parallel-test-orchestration.md](2026-05-29-ph-8p-a-parallel-test-orchestration.md) (closed PR #430 — implementation plan, now shipped)

## Goal

Reconcile master-plan **Phase 8p** tracker and §8p layers table with shipped **8p-a** parallel `li-tests/run_all.sh` (`LI_TEST_JOBS` / `-j N`, isolated `--build-dir` per worker), close stale **#428** (body claims not wired; tree contradicts), and leave **PH-8p partial** until **8p-b** workspace pool and **8p-d** wall-time SLO land (**#385**).

## Non-goals

- Re-implementing `run_all.sh` parallelism (landed via [#186](https://github.com/li-langverse/lic/pull/186), [#200](https://github.com/li-langverse/lic/pull/200)).
- **8p-b** `LI_WORKSPACE_JOBS` pool — **#385** owns that.
- **8p-c** `lic build --jobs` frontend wiring beyond reserved pass — separate track.
- **8p-d** ecosystem baseline `wall_s` SLO — **#385** / follow-up after 8p-b.
- Weakening proof gates, changing `provability-gaps.md` rows (orchestration only; no G-* moves).
- Adding GitHub Actions `schedule:` cron.

## Duplicate check

| Item | Status |
|------|--------|
| **#428** | Stale — opened 2026-05-29 when `run_all.sh` lacked `-j`; evidence now contradicts body |
| **#460** | Canonical reconcile issue (plan verifier audit 2026-05-29) |
| **#385** | Open — 8p-b workspace pool + 8p-d wall-time SLO; **not** closed by this plan |
| **PR #430** | Closed — implementation plan for #428; superseded by shipped code + this reconcile plan |
| **PR #186 / #200** | Merged — 8p-a `LI_TEST_JOBS`, isolated `LI_BUILD_DIR`, `li-jobs.sh` |

## Dependencies

- Shipped tree evidence (audit 2026-05-29):
  - `li-tests/run_all.sh` — `run_parallel()` (~L363–398), `-j` / `LI_TEST_JOBS`, per-worker `--build-dir`
  - `scripts/lib/li-jobs.sh` — `li_test_jobs()` defaults host cores when `CI=true`, else `1`
  - `li-tests/tooling/run_all_parallel_smoke.sh`, `ci_test_jobs_smoke.sh` (`LI_TEST_JOBS=2`)
  - `docs/release-notes/2026-05-25-8p-a-parallel-li-tests.md`
- **#385** — blocks master plan **8p** checkbox completion (8p-b/d).
- Human: **`plan-approved`** before tracker/docs implementation PR.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Close #428** — comment + close as superseded by #460; link smoke scripts + release note | Issue closed with evidence table |
| B | **Master plan §8p layers table** — `li-tests/run_all.sh` row: **Today** = `LI_TEST_JOBS` / `-j`, isolated build dirs (not "One lic build at a time") | Table matches `run_all.sh` on `main` |
| C | **Master plan 8p sub-phases** — mark **8p-a** exit gate **met**; keep **8p-b/c/d** open with links to #385 | `plan-completion-audit` phase `8p` stays partial honest |
| D | **Phase tracker row (L470)** — split: **8p-a done**; **open:** 8p-b workspace pool, 8p-d SLO | Checkbox text no longer implies 8p-a open |
| E | **2026-05-22-parallel-compile-ci.md** — `LI_TEST_JOBS` default row: host cores when `CI=true`, local default `1` (remove "until shipped: **1**") | Env table matches `li-jobs.sh` |
| F | **v2 backlog table (L510)** — clarify 8p-a shipped; remaining = workspace + SLO | Honest v2 wording |
| G | **Release note** (optional) — `docs/release-notes/2026-06-07-ph8p-a-428-reconcile.md` if tracker edit is user-visible | Follow `li-release-notes.mdc` |
| H | **Handoff** — comment on **#385** with 8p-a closure links | No duplicate 8p-b work |

## Tests / benches

| ID | Path | Role |
|----|------|------|
| REQ-8p-a-parallel | `li-tests/run_all.sh` | `-j N` / `LI_TEST_JOBS`, `run_parallel()` job pool |
| REQ-8p-a-isolate | `li-tests/run_all.sh` | Per-worker `--build-dir` / `LI_BUILD_DIR` trees |
| REQ-8p-a-smoke | `li-tests/tooling/run_all_parallel_smoke.sh` | Two concurrent builds, distinct AutoVC paths |
| REQ-8p-a-ci-smoke | `li-tests/tooling/ci_test_jobs_smoke.sh` | `LI_TEST_JOBS=2` CI path |
| REQ-8p-a-jobs-lib | `scripts/lib/li-jobs.sh` | `li_test_jobs()`, `li_workspace_jobs()` defaults |
| REQ-8p-a-gate | `LI_TEST_JOBS=8 ./li-tests/run_all.sh` | 196/196 manifest green (Linux, ≥8 cores) |
| REQ-8p-a-bisect | `LI_TEST_JOBS=1 ./li-tests/run_all.sh` | Identical pass/fail to sequential |

**Gate:** Existing smokes green; no manifest outcome changes in tracker-only PR.

## Provability / G-* updates

| Gap | Move | Notes |
|-----|------|-------|
| **G-lean**, **G-vc**, **G-par** | **Unchanged** | Orchestration only; isolated dirs prevent AutoVC races |
| **provability-gaps.md** | **No edit** unless audit finds scheduling semantics drift (none expected) |

## PH tracker mapping

| PH ID | This plan | Remaining owner |
|-------|-----------|-----------------|
| **PH-8p-a** | Mark **done** in §8p table + sub-phase row | — |
| **PH-8p-b** | Unchanged open | **#385** |
| **PH-8p-c** | Unchanged partial (reserved `--jobs` pass) | Compiler frontend track |
| **PH-8p-d** | Unchanged open (wall_s SLO) | **#385** |
| **PH-8p** | Partial → honest partial (8p-a closed) | #385 + 8p-c completion |

## Rollout

1. Merge this plan PR → add **`plan-approved`** on #460 (human).
2. Docs PR (sub B–F): master plan §8p + tracker + `2026-05-22-parallel-compile-ci.md` env table.
3. Close **#428** (sub A) with superseded comment linking smokes and release notes.
4. Remove **`plan-needed`** from #460; keep **`master-plan-gap`** until #385 closes 8p-b/d.
5. Implementation queue: **#385** for workspace pool + SLO; no re-run of 8p-a codegen.

## Human-only

- Maintainer **`plan-approved`** before tracker edits merge.
- Confirm #428 close reason: superseded (8p-a shipped), not "Phase 8p complete".
- Do not claim **8p** phase checkbox until 8p-b/d exit gates pass (#385).
