# PH-8p exit gates — 8p-b workspace pool + 8p-d wall-time SLO

> **Issue:** [#385](https://github.com/li-langverse/lic/issues/385) · **Repo:** li-langverse/lic  
> **Vision:** **Fast** (CI throughput), **Easy** (predictable local-ci)  
> **Learned from:** [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), [2026-05-25-8p-a-parallel-li-tests.md](../../release-notes/2026-05-25-8p-a-parallel-li-tests.md), [lic-ecosystem-baseline.md](../../ecosystem/lic-ecosystem-baseline.md), master plan § Phase 8p

## Goal

Close the remaining **8p-b** (parallel workspace build job pool) and **8p-d** (wall-time SLO logging) sub-phases so Phase **8p** tracker can flip to `[x]` — building on shipped **8p-a** (`LI_TEST_JOBS` parallel `run_all.sh`) without re-implementing completed slices.

## Non-goals

- Distributed / remote compilation (sccache cluster, Bazel remote).
- Parallel Lean proof search inside a single VC (AutoVC lock semantics unchanged).
- Wiring `lic build --jobs` (**8p-c** — tracked separately in [#525](https://github.com/li-langverse/lic/issues/525)).
- GHA matrix expansion (internal `-j` only; Actions budget).

## Dependencies

- **PH-8p-a** — done: `li-tests/tooling/parallel_run_all_smoke.sh`, `with-autovc-lock.sh`.
- **PH-8p-c/d partial** — smokes exist; this plan completes observability + workspace pool.
- Related: [#428](https://github.com/li-langverse/lic/issues/428), [#460](https://github.com/li-langverse/lic/issues/460) (tracker reconciliation).

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **8p-b** | `scripts/lic-workspace-build.sh` honors `LI_TEST_JOBS` via `xargs -P` or equivalent over workspace members | Wall time ∝ `members/cores` within **~1.3× ideal** on ≥8-core Linux devbox |
| **8p-b** | `benchmarks/harness/bench.py` tier-0 avoids double full `run_all` when manifest already ran in same CI phase | Document ordering in `scripts/ci.sh` |
| **8p-d** | `scripts/local-ci.sh` logs `wall_s` for `run_all` + full local-ci | Baseline row filled in `lic-ecosystem-baseline.md` |
| **8p-d** | `LI_TEST_JOBS=8` vs `=1` on `run_all.sh`: ≤**50%** wall vs sequential (same pass/fail) | Logged once; deterministic |
| **Tracker** | Master plan Phase **8p** `[x]` | All 8p-a/b/c/d gates green (c may remain partial if #525 open — document honestly) |

## Tests / benches

- `li-tests/tooling/parallel_run_all_smoke.sh` (existing — regression guard)
- `li-tests/tooling/ci_test_jobs_smoke.sh`, `resource_flags_smoke.sh`
- New smoke (optional): `workspace_build_parallel_smoke.sh` — 2+ member workspace, `-j2`
- No tier-1 bench ratio claims in this plan.

## Provability

- **No G-* row** — throughput/CI only.
- Must preserve AutoVC isolation: no concurrent Lean typecheck on shared `build/generated/AutoVC.lean`.

## Rollout

1. **lic** draft PR: this plan (doc-only).
2. Implementation PR: `lic-workspace-build.sh` pool + `local-ci.sh` logging.
3. Update ecosystem baseline wall-time table after green local-ci on 8-core host.
4. Close #385 when tracker updated.

## Human-only

- [ ] **`plan-approved`** before implementation PR
- [ ] Confirm 8-core baseline measurement host availability for SLO sign-off
