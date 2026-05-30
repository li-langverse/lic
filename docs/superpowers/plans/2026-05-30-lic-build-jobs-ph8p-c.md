# lic build --jobs / LI_COMPILE_JOBS wiring (PH-8p-c)

> **Issue:** [#525](https://github.com/li-langverse/lic/issues/525) · **Repo:** li-langverse/lic  
> **Vision:** blazingly-fast (CI throughput), easy (documented env vars) · **Learned from:** [master plan § 8p](2026-05-14-li-master-plan.md#phase-8p--parallel-compile--ci-throughput), [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), `compiler/lic/main.cpp` (parse-only today), `platform.hpp` host-core helper

## Goal

Wire `lic build --jobs=N` / `LI_COMPILE_JOBS` to at least one **safe, embarrassingly parallel** compiler pass so large single-TU builds (e.g. `packages/li-net-httpd/src/lib.li`) show measurable wall-time improvement without changing proof semantics. Close the master-plan **8p-c** row honestly: either implement v1 parallelism or document intentional no-op with a follow-up sub-phase gate.

## Non-goals

- Distributed / remote compilation (sccache cluster, Bazel remote).
- Parallel Lean VC discharge inside a single translation unit (shared `AutoVC.lean` hazard).
- Confusing `--jobs` with `lic build --threads=N` (OpenMP **runtime** only).
- Claiming **G-*** provability closure — throughput only; no change to what `lic build` proves.

## Dependencies

- **PH-8p-a** (parallel `run_all.sh`) — ship first or in parallel; largest CI ROI, lower compiler risk per sub-plan ordering.
- **PH-8p-b** workspace pool — independent; do not block 8p-c on full workspace parallelization.
- Sibling checkout for smoke: `packages/li-net-httpd/src/lib.li` compile benchmark.
- Human-only: none for v1 wiring; org CI quota unchanged (internal `-j`, no matrix expansion).

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **8p-c-1** | Audit `LI_COMPILE_JOBS` consumers; add `getenv` helper in `platform.hpp`; log effective job count at `lic build` start | `rg LI_COMPILE_JOBS compiler/` shows ≥1 non-main consumer or explicit documented no-op path |
| **8p-c-2** | Wire first parallel pass (candidate: independent MIR fn lowering batches or LLVM module partition where MIR units are disjoint) behind `--jobs=1` fallback | `lib.li` smoke: `--jobs=4` wall time ≤ **75%** of `--jobs=1` on ≥8-core Linux devbox (single measurement logged in PR) |
| **8p-c-3** | Docs + master plan: update [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md) env table; check **8p-c** sub-gate; registry `gap-plan-debt-lic-master-plan-phase-8p-c` | `plan-completion-audit.py` no longer lists 8p-c as open sub-gate; release note in `docs/release-notes/` |

## Tests / benches

| Path | Purpose |
|------|---------|
| `li-tests/run_all.sh` with `LI_TEST_JOBS=1` vs `8` | No regression in pass/fail after compiler change |
| Smoke: `time lic build packages/li-net-httpd/src/lib.li --jobs=1` vs `--jobs=4` | 8p-c acceptance (issue #525) |
| No new tier-N bench id | Perf-sensitive but compile-time, not runtime kernel — log wall_s in PR body |

## Provability

| G-* | Change |
|-----|--------|
| All rows | **No movement** — parallel scheduling must not alter MIR semantics visible to Lean gate |
| Honest limit | If v1 ships documented no-op, state in plan + `provability-gaps.md` footer that compile parallelism does not affect proof certificates |

## Rollout

1. **lic** PR: `8p-c-1` → `8p-c-2` (same PR if small) → docs (`8p-c-3`).
2. Downstream: benchmarks `plan-completion-audit` JSON refresh on bot branch after merge.
3. Release notes: `docs/release-notes/YYYY-MM-DD-lic-build-jobs-ph8p-c.md`.
4. Close #525 when sub-gates pass; maintainer adds **`plan-approved`** before implementation agents run.
