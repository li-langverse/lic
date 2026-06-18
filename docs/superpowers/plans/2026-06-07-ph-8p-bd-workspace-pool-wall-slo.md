# PH-8p-b/d — Parallel workspace pool + wall-time SLO

> **Issue:** [#385](https://github.com/li-langverse/lic/issues/385) · **Repo:** li-langverse/lic  
> **Parent:** [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md) · **Master plan:** [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) § Phase 8p  
> **Vision pillars:** **Fast** (CI throughput after proof) · **Easy** (predictable `local-ci.sh`)  
> **north_star_fit:** HPC / agent CI path · **PH-8p-b**, **PH-8p-d**  
> **Learned from:** [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), [2026-05-25-8p-a-parallel-li-tests.md](../../release-notes/2026-05-25-8p-a-parallel-li-tests.md), [2026-05-25-8p-cd-compile-jobs-ci-smokes.md](../../release-notes/2026-05-25-8p-cd-compile-jobs-ci-smokes.md), [lic-ecosystem-baseline.md](../../ecosystem/lic-ecosystem-baseline.md)

## Goal

Close the remaining **8p-b** (parallel `lic-workspace-build.sh` job pool) and **8p-d** (wall-time SLO logging) sub-phases so the master-plan **Phase 8p** tracker can flip to `[x]`. Builds on shipped slices — does **not** re-implement them.

## Shipped (do not re-implement)

| Sub | Evidence | Notes |
|-----|----------|-------|
| **8p-a** | `li-tests/run_all.sh` + `LI_TEST_JOBS` / `-j N`, isolated `LI_BUILD_DIR`, `with-autovc-lock.sh` | [#186](https://github.com/li-langverse/lic/pull/186), [#200](https://github.com/li-langverse/lic/pull/200) |
| **8p-c** | `lic build --jobs=N` → `LI_COMPILE_JOBS` wired in compiler | [#525](https://github.com/li-langverse/lic/issues/525) closed |
| **8p-d partial** | `scripts/ci.sh` uses explicit `run_all.sh -j8 --max-memory=8192`; `ci_test_jobs_smoke.sh`, `resource_flags_smoke.sh` | `LI_TEST_JOBS` not exported in CI by design |

## Non-goals

- Distributed / remote compilation (sccache cluster, Bazel remote).
- Parallel Lean proof search inside a single VC (AutoVC lock semantics unchanged).
- GHA matrix expansion (internal `-j` only; Actions budget).
- Tier-1 benchmark ratio claims or `threshold_ratio_cpp` changes.

## Problem (current state)

1. **`lic-workspace-build.sh`** iterates workspace members **sequentially** despite `scripts/lib/li-jobs.sh` already exposing `li_workspace_jobs()` (inherits `LI_TEST_JOBS` / `LI_WORKSPACE_JOBS`).
2. **`bench.py --tier 0`** calls `run_all.sh` then `verify.py`, but `scripts/ci.sh` already runs full manifest `run_all` immediately before tier-0 — duplicate sweep wastes wall time.
3. **`local-ci.sh`** exits without logging `wall_s`; ecosystem baseline table rows remain `not measured`.

## Implementation plan

### Slice 1 — 8p-b workspace parallel pool

**Files:** `scripts/lic-workspace-build.sh`, `scripts/lib/li-jobs.sh` (read-only unless helper needed), `li-tests/tooling/workspace_build_parallel_smoke.sh` (new, optional but recommended)

1. Source `scripts/lib/li-jobs.sh`; resolve `JOBS="$(li_workspace_jobs)"`.
2. Replace sequential `for m in "${members[@]}"` with a job pool:
   - Preferred: `printf '%s\0' … | xargs -0 -P "$JOBS" -I{} bash -c 'build_one_member "$@"' _ {}`
   - Each worker builds one member with existing smoke/lib.li logic; preserve `li-demo` skip.
3. **Isolation:** each worker must use a distinct `LI_BUILD_DIR` (same pattern as `run_all.sh` workers) so AutoVC paths do not race.
4. Aggregate exit codes; preserve footer `lic-workspace-build: ok (N members)`.
5. Smoke: `LI_WORKSPACE_JOBS=2 ./scripts/lic-workspace-build.sh packages/li.toml` on ≥2 non-demo members; assert pass + faster than `=1` on 4+ core host.

**Exit gate:** wall time ∝ `members/cores` within **~1.3× ideal** on ≥8-core Linux devbox with LLVM 22 + Lean.

### Slice 2 — 8p-b tier-0 dedup

**Files:** `benchmarks/harness/bench.py`, `scripts/ci.sh`

1. Add env `LI_TIER0_SKIP_RUN_ALL=1` (or `--skip-run-all` flag on `bench.py --tier 0`) so tier-0 runs `verify.py` + `stability.py` only when manifest already ran in the same CI phase.
2. Set the flag in `scripts/ci.sh` between the full-manifest `run_all` phase and `bench.py --tier 0`.
3. Document ordering in a one-line comment in `ci.sh` (no behavior change when flag unset — local `bench.py --tier 0` still self-contained).

**Exit gate:** tier-0 phase wall time drops vs current duplicate `run_all`; manifest pass/fail unchanged.

### Slice 3 — 8p-d wall-time observability

**Files:** `scripts/local-ci.sh`, `docs/ecosystem/lic-ecosystem-baseline.md`, optional `scripts/lib/ci-timing.sh`

1. Wrap `scripts/ci.sh` invocation in `local-ci.sh` with `/usr/bin/time` or `date +%s` delta; emit `local-ci wall_s=<N>` to stdout (and optionally `benchmarks/data/latest/local-ci-results.json` when `LI_CI_RECORD=1`).
2. Inside `ci.sh` or `run_all.sh` footer: log `run_all wall_s=<N>` for the full-manifest phase (both `-j1` and `-j8` reference runs).
3. After green run on 8-core devbox, fill baseline table:

| Metric | `run_all -j1` | `run_all -j8 --max-memory=8192` | Notes |
|--------|---------------|-----------------------------------|--------|
| **wall_s** (full manifest) | measured | measured | Target: `-j8` ≤ **50%** of `-j1` |

4. Update master-plan tracker row **8p** when all sub-gates green.

**Exit gate:** baseline row populated; SLO ≤50% documented with measurement date/host.

## PH / REQ / gap mapping

| ID | Scope |
|----|-------|
| **PH-8p-b** | Workspace parallel pool + tier-0 dedup |
| **PH-8p-d** | `wall_s` logging + baseline SLO |
| **REQ-CI-par** | Implicit — parallel CI without weakening proof gates |
| **G-*** | **None** — throughput only; proof surface unchanged |

## Tests / benches

| Gate | Command |
|------|---------|
| Regression | `li-tests/tooling/parallel_run_all_smoke.sh` |
| Jobs helper | `li-tests/tooling/ci_test_jobs_smoke.sh` |
| Resource flags | `li-tests/tooling/resource_flags_smoke.sh` |
| New (recommended) | `li-tests/tooling/workspace_build_parallel_smoke.sh` |
| Full gate | `HTTPD_SKIP_LI_ROUTING_BIN=1 ./scripts/local-ci.sh` |

## Provability & safety

1. **No G-* row** — scheduling only; `lic build` proof certificates unchanged.
2. **AutoVC isolation** — per-worker `LI_BUILD_DIR`; no concurrent Lean on shared `build/generated/AutoVC.lean`.
3. **`LI_TEST_JOBS=1`** remains bisect/golden default outside `CI=true`.

## Rollout (two PRs)

| PR | Scope | Labels |
|----|-------|--------|
| **Plan (this doc)** | Doc-only; `plan-approved` gate | `documentation`, `master-plan-gap` |
| **Implementation** | Slices 1–3 + baseline + tracker `[x]` | `enhancement`, closes #385 |

## Human-only

- [ ] **`plan-approved`** before implementation PR
- [ ] 8-core devbox available for SLO sign-off measurement
- [ ] Confirm `li-demo` skip policy still correct after parallel pool
