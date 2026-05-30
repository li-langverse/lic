# PH-7d / G-par — MIR proc tags + Lean disjoint proofs

> **Issue:** [#387](https://github.com/li-langverse/lic/issues/387) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (disjoint parallelism), **Secure** (race = compile error), **Fast** (decorator lowering to SIMD/parallel)  
> **Learned from:** [provability-gaps.md](../../verification/provability-gaps.md) (**G-par**, **G-dec**), [2026-05-14-phase-07-native-hpc.md](2026-05-14-phase-07-native-hpc.md), `li-tests/decorators/`, `li-tests/race_shared_memory/`, master plan § Phase 7d

## Goal

Complete **Phase 7d** lowering beyond `@vectorized for` scope: full **MIR proc tags** for `@parallel` / `@vectorized` on `def`, plus **Lean G-par** discharge corpus — so **G-par** moves from **Partial** (AST heuristics) toward **Done** without runtime race surprises.

## Non-goals

- `@gpu` device buffer proofs (**G-gpu** — Phase 3+).
- Full `@async` structured concurrency proofs (**G-async** — partial, separate track).
- Tier-2 MD benchmark decorator perf claims without bench evidence ([#429](https://github.com/li-langverse/lic/issues/429) harness plan).
- Weakening `disjoint=` to runtime checks.

## Dependencies

- **PH-7d-a/e** — parse + policy slices shipped.
- **PH-7d-c partial** — `@vectorized` on `for` → `ArraySimdScope` (#150).
- **PH-7b** — structured `disjoint=` surface.
- Complements [#32](https://github.com/li-langverse/lic/issues/32) (Lean 2e–2f/7e) but scoped to **7d** decorator lowering.
- **Human-only:** `trusted.lean` changes require maintainer-approved issue per swarm mandate.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **MIR proc tags** — `@parallel` / `@vectorized` on `def` emit `MirFn.decorators` with proc-level tags (not only `for` scope) | New `li-tests/decorators/*_def_ok.li` compile_ok |
| B | **Lowering** — proc tags inherit to nested `parallel for` per policy; `@vectorized def` body → `ArraySimdScope` where applicable | `execution_resources/smoke.sh` green |
| C | **G-par Lean corpus** — discharge iteration independence for structured `disjoint=` patterns (start with row/col grid templates) | Lean CI green; no new `sorry` in user-facing proofs |
| D | **Exploit corpus** — extend `decorator_exploits/` for false disjoint, mut capture, borrow-in-par on **def** decorators | All `compile_fail` with stable diagnostic codes |
| E | **Provability doc** — update **G-par** / **G-dec** rows in `provability-gaps.md`; link phase-07 exit gates | Honest **Partial→Done** slice documented |
| F | **Tracker** — master plan Phase **7d** checkbox when A–E pass | Cross-link #387 |

## Tests / benches

- `li-tests/decorators/vectorized_for_scope_ok.li` (existing regression)
- `li-tests/race_shared_memory/` (disjoint policy)
- `li-tests/decorator_exploits/missing_disjoint_at_parallel.li`
- New: `decorators/parallel_def_disjoint_ok.li`, `decorators/vectorized_def_scope_ok.li`
- Tier-2 advisory (optional, post-lowering): MD kernels with `@cpu/@parallel/@vectorized` on `def` — **lic** harness only; catalog in **benchmarks** after green tier-2 ratio.

## Provability

| G-* | Current | Target after plan |
|-----|---------|-------------------|
| **G-par** | Partial — AST `check_module_policies` + string heuristics | Partial→**Done** for structured `disjoint=` + proc-tag lowering slice |
| **G-dec** | Partial — parse + policy + partial MIR | Partial→**Done** for `@parallel`/`@vectorized` on `def` elaboration |
| Honest limit | General pointer aliasing / GPU | Remains open; document in phase-07 |

## Rollout

1. **lic** draft PR: this plan (doc-only).
2. Implementation stack: A→B (MIR/tags) before C (Lean); D in parallel with B.
3. **proof_gap_researcher** handoff: sub-phase C — catalog open **G-par** proof obligations before `trusted.lean` edits.
4. Update master plan § 7d when F passes.

## Human-only

- [ ] **`plan-approved`** before MIR/Lean implementation PRs
- [ ] Any `trusted.lean` change: separate maintainer ack per org policy
