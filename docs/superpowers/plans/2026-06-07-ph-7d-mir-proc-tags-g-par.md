# PH-7d / G-par — MIR proc tags + Lean disjoint proofs

> **Issue:** [#387](https://github.com/li-langverse/lic/issues/387) · **Repo:** li-langverse/lic  
> **Vision:** provable (disjoint parallelism) → secure (race = compile error) → fast (decorator lowering to SIMD/parallel)  
> **north_star_fit:** Scientific computing / HPC · **PH-7d** · **G-par**, **G-dec**

**Learned from:**

1. [provability-gaps.md](../../verification/provability-gaps.md) — **G-par** / **G-dec** honest inventory
2. [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md) § 7d + exit gate L75 (Doc-c **G-par** cross-links)
3. [2026-05-16-li-execution-decorators.md](../specs/2026-05-16-li-execution-decorators.md) — compile-time elaboration, no runtime registry
4. `li-tests/decorators/parallel_def_disjoint_inherit.li`, `parallel_with_disjoint.li`, `vectorized_dot_proc_ok.li` — proc-tag vs loop-tag delta
5. `docs/semantics/Discharge.lean` § **P-par** — policy witnesses vs iteration-independence proofs

> Supersedes closed draft [PR #540](https://github.com/li-langverse/lic/pull/540) (2026-05-30 plan never merged). Complements [#429](https://github.com/li-langverse/lic/issues/429) tier-2 MD workload plan ([PR #1003](https://github.com/li-langverse/lic/pull/1003)) — **#429** exercises decorator `def` in production harness; **#387** closes MIR parity + **G-par** Lean discharge.

## Goal

Complete **Phase 7d** lowering beyond `@vectorized for` scope:

1. **Full MIR proc tags** for `@parallel` / `@vectorized` on `def` — proc-level tags drive nested `parallel for` / `ArraySimdScope` lowering without requiring duplicate loop-level decorators or `requires disjoint_*` on every inner loop.
2. **Lean G-par corpus** — discharge iteration independence for structured `disjoint=` patterns beyond `compile_fail` policy slices.
3. **Doc-c** — link [phase-07 exit gates](2026-05-14-phase-07-native-hpc.md#exit-gate-phase-complete) to **G-par** row IDs in `provability-gaps.md`.

So **G-par** moves from **Partial** (AST heuristics + trivial policy witnesses) toward an honest **Done** slice for structured `disjoint=` + proc-tag lowering — without runtime race surprises.

## Non-goals

- `@gpu` device buffer proofs (**G-gpu** — Phase 3+).
- Full `@async` structured concurrency proofs (**G-async** — separate track).
- Tier-2 MD benchmark decorator perf claims — tracked in **#429**; no `threshold_ratio_cpp` weakening.
- Weakening `disjoint=` to runtime checks.
- General pointer aliasing / GPU address-space proofs — remain open; document in phase-07.
- `trusted.lean` edits without maintainer-approved issue (org swarm mandate).

## Current state (2026-06-07)

| Asset | Status |
|-------|--------|
| **7d-a/e** parse + policy | `decorator_exploits/` CI green |
| `@vectorized` on `for` → `ArraySimdScope` | `vectorized_for_scope_ok.li` — **partial done** (#150) |
| `@vectorized` on `def` MIR telemetry | `mir_vectorized_proc=1` on `vectorized_dot_proc_ok.li`; `check-mir-vectorized-decorator.sh` |
| `@parallel(disjoint=)` on `def` + loop `requires` | `parallel_with_disjoint.li` → `mir_parallel_disjoint=1`; OpenMP symbol smoke |
| `@parallel(disjoint=)` on `def` **inherit only** | `parallel_def_disjoint_inherit.li` — `compile_ok`; **no** `mir_parallel_disjoint` on proc; nested loop lacks loop-level `requires disjoint_*` |
| Policy proc inherit | `parallel_for_disjoint_witness(stmt, proc_decorators)` in `policy_module.cpp` |
| MIR proc tag copy | `copy_decorators(proc → MirFn.decorators)` + `disjoint_proven` heuristic |
| Lean **P-par** | `Discharge.lean` — `disjoint_*_policy_witness` theorems (`True` stubs); `discharge_par_parallel_lean.sh` on keyword `parallel for` only |
| Phase-07 L75 | **Open** — tier-2 MD `@` on `def` (**#429**) |
| Master plan § 7d checkbox | **Open** — "full MIR proc tags, Lean **G-par** proofs" |

**Gap (this issue):** proc-level `@parallel(disjoint=…)` / `@vectorized` must fully elaborate to the same MIR + codegen path as keyword `parallel for` / scoped `for` vectorization — and **G-par** Lean must prove iteration independence for the structured templates, not only accept policy strings.

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-7d-a/e** | Parse + policy slices shipped |
| **PH-7d-c partial** | `@vectorized` on `for` → `ArraySimdScope` (#150) |
| **PH-7b** | Structured `disjoint=` surface + `race_shared_memory/` |
| **#32** | Lean 2e–2f/7e corpus — complements; **#387** scoped to 7d decorator lowering |
| **#429** | Tier-2 MD workload uses decorator `def`; needs MIR parity test from sub-phase D here |
| **Human-only** | Any `trusted.lean` change — separate maintainer ack |

## Plan home

- **This file** — lic compiler + Lean proof plan
- **Master plan** — checkbox line 457 in [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md)
- **Phase-07** — 7d sub-table + Doc-c **G-par** anchor links (sub-phase E)

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A — MIR proc tags** | `@parallel` / `@vectorized` on `def` emit complete `MirFn.decorators` with `disjoint_proven`, `lanes`, `vectorized` flags; proc tags drive nested lowering | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1`; new `vectorized_def_scope_ok.li` → `mir_vectorized_proc=1` + body `ArraySimdScope` |
| **B — Lowering inherit** | Proc `@parallel(disjoint=…)` inherits to nested `parallel for` without loop-level duplicate; `@vectorized def` body → `ArraySimdScope` where applicable; keyword path bit-identical MIR diff test | `execution_resources/smoke.sh` green; `check-mir-parallel-decorator.sh` extended for inherit specimen |
| **C — G-par Lean corpus** | Replace trivial `True` policy witnesses with iteration-independence specs for `disjoint_elem`, `disjoint_row`, `disjoint_slice` grid templates; AutoVC `_par*` obligations discharge | `discharge_par_parallel_lean.sh` + new `discharge_par_def_inherit_lean.sh` green; **no** new `sorry` in user-facing proofs |
| **D — Exploit corpus** | Extend `decorator_exploits/` for false disjoint, mut capture, borrow-in-par on **def** decorators (not only `for`) | All `compile_fail` with stable `E0321`/`E0322` codes |
| **E — Provability doc (Doc-c)** | Update **G-par** / **G-dec** rows in `provability-gaps.md`; add phase-07 exit-gate anchors → **G-par** IDs; cross-link **#429** honest limit | Honest **Partial→Done** slice documented; L75 closure still **#429** |
| **F — Tracker** | Master plan Phase **7d** checkbox when A–E pass | Cross-link **#387** closed |

### MIR parity sketch (sub-phase A/B)

Keyword reference vs decorator `def` must produce equivalent MIR tags:

```li
# Keyword path (reference)
def force_step_kw(...) -> unit =
  parallel for i in 0..<N
    requires disjoint_row(i, grid)
  = ...

# Decorator path (target — proc tag drives nested loop)
@cpu
@parallel(disjoint=disjoint_row)
@vectorized(lanes=4)
def force_step(...) -> unit =
  parallel for i in 0..<N
  = ...
```

Exit: `lic verify` telemetry + MIR diff script (or documented delta with test) shows proc-tag path ≡ keyword path for disjoint + vectorized scopes.

### Lean handoff (sub-phase C)

**Owner:** `proof_gap_researcher` before any `trusted.lean` edit.

1. Catalog open **G-par** obligations from `parallel_def_disjoint_inherit.li` and `good_disjoint_parallel.li` AutoVC output.
2. Strengthen `disjoint_row_spec` / `disjoint_elem_spec` from `Prop := True` to iteration-independence predicates over `LiArray` index writes.
3. Land witnesses in `Discharge.lean` (or `Li.Trusted` only with maintainer issue).
4. Wire `contracts_discharge_corpus.sh` row for decorator-inherit specimen.

## PH / REQ / G-* mapping

| ID | Movement |
|----|----------|
| **PH-7d** | Partial → **Done** (when A–F pass; master plan checkbox) |
| **REQ-7d-mir-proc-tags** | Proc-level `@parallel`/`@vectorized` on `def` emit full MIR tags |
| **REQ-7d-mir-parity** | Decorator elaboration ≡ keyword MIR for structured disjoint + vectorized |
| **REQ-7d-gpar-lean** | Lean discharge for structured `disjoint=` templates |
| **G-par** | Partial → **Done** slice for structured `disjoint=` + proc-tag lowering |
| **G-dec** | Partial → **Done** slice for `@parallel`/`@vectorized` on `def` elaboration |
| **P-par** | Partial → closed VCs for inherit + grid templates |

**Honest limit:** Closing **#387** does **not** alone check phase-07 L75 (tier-2 MD workload — **#429**). L75 can land with documented MIR delta until A/B pass.

## Tests / benches

| Gate | Command / artifact |
|------|-------------------|
| Decorator regressions | `./li-tests/run_all.sh decorators decorator_exploits` |
| Disjoint policy | `./li-tests/run_all.sh race_shared_memory` |
| Proc inherit (new) | `parallel_def_disjoint_inherit.li` → `mir_parallel_disjoint=1` |
| Vectorized def scope (new) | `vectorized_def_scope_ok.li` |
| MIR smokes | `scripts/check-mir-parallel-decorator.sh`, `check-mir-vectorized-decorator.sh` |
| Lean P-par | `li-tests/tooling/discharge_par_parallel_lean.sh`, `discharge_par_def_inherit_lean.sh` (new) |
| Execution resources | `li-tests/execution_resources/smoke.sh` |
| Tier-2 advisory | Optional after B — **#429** workload; catalog in **benchmarks** |

## Vision checks

| Check | Result |
|-------|--------|
| Proof-before-perf | Yes — MIR parity + Lean **G-par** before perf claims |
| Strict-by-default | Yes — `decorator_exploits` remain fail-closed |
| Benchmark threshold gaming | **Rejected** — no `threshold_ratio_cpp` weakening |
| New org repo | Not needed |
| `trusted.lean` | Human-only per sub-phase C |

## Rollout (implementation PRs, post-`plan-approved`)

1. **lic PR 1 (MIR):** sub-phases A + B + D — `lower.cpp`, `mir.hpp`, tests, CI scripts.
2. **lic PR 2 (Lean):** sub-phase C — `Discharge.lean` + tooling; **proof_gap_researcher** review.
3. **lic PR 3 (docs):** sub-phase E + F — `provability-gaps.md`, phase-07 Doc-c anchors, master plan checkbox.
4. Unblock **#429** implementer for MIR parity test (sub-phase D of #429 plan).
5. Close **#387** when acceptance boxes checked.

## Human-only

- [ ] Review and merge this plan PR
- [ ] Add label **`plan-approved`** on [#387](https://github.com/li-langverse/lic/issues/387)
- [ ] Remove **`plan-needed`** after ack
- [ ] Route MIR PRs to **code_implementer**; Lean sub-phase C to **proof_gap_researcher**
- [ ] Separate maintainer ack for any `trusted.lean` change
