# lic build --jobs / LI_COMPILE_JOBS wiring (PH-8p-c)

> **Issue:** [#525](https://github.com/li-langverse/lic/issues/525) · **Repo:** li-langverse/lic  
> **Vision:** **Fast** (CI / large-TU compile throughput), **Easy** (canonical `--jobs` / env table) · **Learned from:** [master plan § 8p](2026-05-14-li-master-plan.md#phase-8p--parallel-compile--ci-throughput), [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md), [2026-05-25-8p-cd-compile-jobs-ci-smokes release note](../release-notes/2026-05-25-8p-cd-compile-jobs-ci-smokes.md), `compiler/codegen/emit.cpp` (Pass 2 per-fn bodies)

**north_star_fit:** HPC / web gateway compile path · **PH-8p-c** (throughput; no **G-*** movement)

## Goal

Close the honest gap between **reserved** and **wired** compile parallelism: `lic build --jobs=N` / `LI_COMPILE_JOBS` must drive at least one safe, embarrassingly parallel compiler pass so large single-TU builds (e.g. `packages/li-net-httpd/src/lib.li`) show measurable wall-time improvement without changing proof semantics or Lean gate behavior.

## Current state (2026-06-04 audit)

| Layer | Status |
|-------|--------|
| CLI / env parse | **Done** — `ResourceOptions`, `apply_resource_flag`, `finalize_resource_options` read `--jobs` and `LI_COMPILE_JOBS` ([`compiler/common/resource_options.cpp`](../../../compiler/common/resource_options.cpp)) |
| Reserved budget export | **Done** — `note_compile_jobs_reserved`, `compile_jobs_reserved()`, env re-export in `lic build` ([`compiler/lic/main.cpp`](../../../compiler/lic/main.cpp)) |
| Codegen consumer | **Missing** — `compile_jobs_from_options()` in [`platform.hpp`](../../../compiler/codegen/include/li/platform.hpp) has **zero call sites** outside its definition |
| Release honesty | Documented in [8p-cd release note](../release-notes/2026-05-25-8p-cd-compile-jobs-ci-smokes.md): *"Parallel MIR/LLVM frontend passes (reserved job count only)"* |

Supersedes closed draft [PR #536](https://github.com/li-langverse/lic/pull/536) (plan-only, unmerged); this file is the canonical plan for implementers.

## Non-goals

- Distributed / remote compilation (sccache cluster, Bazel remote).
- Parallel Lean VC discharge or concurrent writes to shared `build/generated/AutoVC.lean`.
- Confusing `--jobs` with `lic build --threads=N` (OpenMP **runtime** only — see [execution-resources spec](../specs/2026-05-25-li-execution-resources.md)).
- Claiming **G-*** provability closure — scheduling only; proof certificates unchanged.
- **8p-b** workspace pool or **8p-d** wall-time SLO (separate issues; do not block 8p-c).

## Dependencies

- **PH-8p-a** parallel `run_all.sh` — prefer shipped before or in parallel; largest CI ROI, lower compiler risk ([8p sub-plan ordering](2026-05-22-parallel-compile-ci.md)).
- Smoke target present: `packages/li-net-httpd/src/lib.li` (~1.1k LOC).
- Human-only: **`plan-approved`** label before product-code agents; no self-merge of this plan PR.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **8p-c-1** | **Wire budget** — call `compile_jobs_from_options()` from `compile_module` / `emit_llvm_ir`; log effective jobs at `lic build` start when `LI_COMPILE_JOBS_LOG=1` | `rg compile_jobs_from_options compiler/` shows ≥1 consumer; `--jobs=1` bit-identical LLVM module hash vs baseline on `greeter.li` smoke |
| **8p-c-2** | **First parallel pass** — parallelize **emit Pass 2** (per-`MirFn` body emission) behind job pool; Pass 1 (declare all symbols) stays serial | No data races on shared `llvm::Module` (one `LLVMContext`; workers only IR-build into distinct `llvm::Function*`); fallback to serial when `jobs==1` |
| **8p-c-3** | **Smoke + CI** — add `li-tests/tooling/compile_jobs_httpd_smoke.sh`; optional row in `scripts/ci.sh` 8p phase | On ≥8-core Linux: `time lic build packages/li-net-httpd/src/lib.li -o /dev/null --jobs=4` wall ≤ **75%** of `--jobs=1` (single logged measurement in PR body) |
| **8p-c-4** | **Tracker + registry** — update master plan § 8p row, [parallel-compile-ci](2026-05-22-parallel-compile-ci.md) env table, `gap-plan-debt-lic-master-plan-phase-8p-parallel-compile-ci-thr` in [`data/swarm-gap-registry/registry.yaml`](../../../data/swarm-gap-registry/registry.yaml); release note `docs/release-notes/YYYY-MM-DD-lic-build-jobs-ph8p-c.md` | `plan-completion-audit` no longer lists 8p-c as open sub-gate; close **#525** |

## Implementation sketch (8p-c-2)

1. In `emit_llvm_ir` ([`emit.cpp`](../../../compiler/codegen/emit.cpp)):
   - Pass 1: unchanged serial loop over `mir.functions` (declare linkage).
   - Pass 2: partition `user_fns` across `std::min(compile_jobs_from_options(), user_fns.size())` workers.
2. Thread-safety: do not share `llvm::IRBuilder` across threads; each worker owns one function body.
3. Determinism: stable partition order; `jobs=1` uses existing serial loop (no pool).
4. Do **not** parallelize `lower_to_mir`, Lean verify, or clang link in v1.

## Tests / benches

| Path | Purpose |
|------|---------|
| `li-tests/tooling/resource_flags_smoke.sh` | Regression: env/flag precedence unchanged |
| `li-tests/tooling/compile_jobs_httpd_smoke.sh` (**new**) | #525 acceptance: `--jobs=1` vs `4` wall on httpd `lib.li` |
| `li-tests/run_all.sh` `LI_TEST_JOBS=1` | No pass/fail drift after codegen change |
| Tier-N bench id | **None** — compile-time only; log `wall_s` in PR |

## Provability

| G-* | Change |
|-----|--------|
| All rows | **No movement** — parallel scheduling must not alter MIR semantics visible to Lean |
| Honest limit | Footer in [provability-gaps.md](../../verification/provability-gaps.md): compile parallelism does not change what `lic build` proves |

## Rollout

1. **lic** implementation PR (after **`plan-approved`**): 8p-c-1 → 8p-c-2 → 8p-c-3 → 8p-c-4 in one or two PRs.
2. Downstream: optional `plan-completion-audit` registry refresh on bot branch post-merge.
3. Close **#525** when all sub-gates pass.

## Human-only checklist

- [ ] Review and merge this plan PR
- [ ] Add label **`plan-approved`** on #525
- [ ] Remove **`plan-needed`** after ack
