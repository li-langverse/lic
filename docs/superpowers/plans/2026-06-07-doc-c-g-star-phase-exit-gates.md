# Doc-c: G-* register IDs in phase 02 / 03 / 07 exit gates

> **Issue:** [#31](https://github.com/li-langverse/lic/issues/31) (canonical) · **Related:** [#26](https://github.com/li-langverse/lic/issues/26), [#29](https://github.com/li-langverse/lic/issues/29)  
> **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest gap linkage) → **Easy** (agents find G-* from phase plans)  
> **north_star_fit:** Documentation / provability honesty · **PH-Doc-c** · **G-*** (per-phase register rows)  
> **Learned from:** [master plan § Doc](2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting), [provability-gaps.md](../../verification/provability-gaps.md), [plan-cross-links.md](../../ecosystem/plan-cross-links.md), [ph7e-tier1-red-benchmark-honesty](2026-05-30-ph7e-tier1-red-benchmark-honesty.md) (doc-only plan pattern)

## Goal

Close master-plan tracker debt **Doc-c** by making phase plan exit gates **explicitly cite** every applicable **G-*** row from [`provability-gaps.md`](../../verification/provability-gaps.md) (or **N/A** with one-line rationale), reconciling the contradictory Doc-c definitions in the master plan, and updating spec stubs so decorator/math cross-links match the same register format.

## Problem (current state on `main`)

| Signal | Status |
|--------|--------|
| Phase 02 / 03 / 07 headers | **Partial** — `Proof gaps (Doc-c):` bullet lists exist at file top (02) or pre-exit (03) |
| Phase exit gate sections | **Gap** — exit bullets do not name **G-*** IDs per acceptance on #31 |
| Master plan sub-phase **Doc-c** row | Says **spec stubs** (decorator + math surface docs) — unchecked concept |
| Master plan checklist **Doc-c** | Says phase 02/03/07 exit gates — marked `[x]` prematurely |
| Spec stubs | **Partial** — `2026-05-16-li-math-linalg-surface.md` has Doc-c block; `2026-05-16-li-execution-decorators.md` uses informal `Gaps:` line only |
| Duplicate issues | #12, #23, #26, #29, #31 — same Doc-c scope |

**Blocker (#29):** plan-verifier cannot close Doc-c honestly while checklist `[x]` and sub-phase table disagree.

## Non-goals

- Closing any **G-*** row to **Done** (documentation cross-link only).
- Compiler, Lean, or `trusted.lean` changes.
- Weakening benchmark thresholds or claiming proof from doc edits.
- Merging duplicate issues without maintainer ack (recommend in rollout).

## Dependencies

- Living register: [`docs/verification/provability-gaps.md`](../../verification/provability-gaps.md).
- Master plan compiler-task map (§ *Compiler tasks vs proof gaps*).
- `docs-maintainer` or `code_implementer` lane after **`plan-approved`**.

## G-* inventory (phase → exit gate)

Derived from master plan § *Compiler tasks vs proof gaps* and register **Phase** column. Implementation PR must add an **Exit gate — G-* register** subsection to each phase plan.

### Phase 02 (`2026-05-14-phase-02-typechecker.md`)

| G-* ID | Applicability | Exit-gate evidence (today) | Notes |
|--------|---------------|------------------------------|-------|
| **G-vc** | **Yes** | `li-tests/contracts_verify/`, `vc_emit_contracts.sh` (partial — typecheck emits contract hooks) | Primary 2e overlap; cite partial status |
| **G-bnd** | **Yes** | Literal index bounds at typecheck; release path open | Links to phase 3 for MIR |
| **G-def** | **Yes** | `li-tests/encapsulation/`, method/`self` surface | PH-2j overlap |
| **G-math-syn** | **Yes** | `li-tests/math_syntax/` | PH-2h |
| **G-narrow** | **Yes** | `historic_ariane5_narrowing.li` reject | 2e policy |
| **G-oop** | **Yes** | trait/method tests partial | PH-2j |
| **G-lean** | **N/A** | — | Lean gate is **2f**, not phase-02 exit |
| **G-ann** | **N/A** | — | Phase 4 deferred annotations |
| **G-par** | **N/A** | — | Phase 7b parallel surface |
| **G-meta** | **N/A** | — | Research limit per master plan |

### Phase 03 (`2026-05-14-phase-03-mir-codegen.md`)

| G-* ID | Applicability | Exit-gate evidence (today) | Notes |
|--------|---------------|------------------------------|-------|
| **G-bnd** | **Yes** | `check_release_bounds_ir.sh`, `panic_if_oob` in MIR | Primary phase-3 gap |
| **G-vc** | **Yes** | MIR lowering preserves contract sites; AutoVC emission | Partial — ties to 2e/2f |
| **G-gpu** | **Partial cite** | MIR `@gpu` telemetry scripts | Wave 13 slice only |
| **G-meta** | **N/A** | — | Compiler-correctness research; not phase-3 deliverable |
| **G-dec** | **N/A** | — | Phase 7d elaboration |
| **G-math** | **N/A** | — | Lowering in phase 7e (math→SIMD) |

### Phase 07 (`2026-05-14-phase-07-native-hpc.md`)

| G-* ID | Applicability | Exit-gate evidence (today) | Notes |
|--------|---------------|------------------------------|-------|
| **G-par** | **Yes** | `li-tests/race_shared_memory/`, `good_disjoint_parallel.li` | 7b — Lean proofs open |
| **G-dec** | **Yes** | `li-tests/decorators/`, `decorator_exploits/` | 7d — elaboration partial |
| **G-math** | **Yes** | `li-tests/math_linalg/`, tier-1 advisory benches | 7e — see [ph7e plan](2026-05-30-ph7e-tier1-red-benchmark-honesty.md) |
| **G-gpu** | **Yes** | `ml_gpu_device_buffer.li`, `check-mir-gpu-decorator.sh` | Partial address-space proofs |
| **G-lean** | **Partial cite** | P-linalg / P-par open in exit 7e row | Cross-link only; closure is 2f |

## Sub-phases (implementation — after `plan-approved`)

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Reconcile master plan Doc-c** — split or rename: **Doc-c₁** phase exit gates vs **Doc-c₂** spec stubs; fix contradictory `[x]` | Single definition; checklist matches sub-phase table |
| **B** | **Phase 02** — add `### Exit gate — G-* register` table + mirror IDs in exit bullets | Every applicable row cited or N/A rationale |
| **C** | **Phase 03** — move proof-gap block immediately above exit gate; add G-* table | Same as B |
| **D** | **Phase 07** — consolidate header + 7a–7e sub-gates into one exit G-* table | Includes 7d/7e cross-refs |
| **E** | **Spec stubs** — normalize `2026-05-16-li-execution-decorators.md` to Doc-c format (`G-dec`, `G-par`, `G-gpu`) | Matches math-linalg surface pattern |
| **F** | **plan-cross-links.md** — add Doc-c row under phase index | Agents discover mapping |
| **G** | **Master plan checkbox** — check Doc-c only when A–F land in same PR | Honesty policy per strict-by-default |

## Tests / verification

| Check | Command / review |
|-------|------------------|
| G-* anchors resolve | Manual: each linked `#g-*` opens register row |
| No naked “provability” in exit gates | `rg -n 'provability' docs/superpowers/plans/2026-05-14-phase-0[237]*.md` — must pair with **G-*** |
| Doc claim guard (optional) | `./scripts/check-doc-provability-claims.sh` on changed docs |
| Plan-verifier | Re-run on #29 — contradiction cleared |

## Provability

| Gap | Action |
|-----|--------|
| All **G-*** | **No status change** — cross-links only; rows stay Partial/Stub/Missing |
| **G-meta**, **G-hw**, **G-wrong-spec** | Explicit **N/A** at phase exit where master plan lists as limits |

## Rollout

1. Merge this plan PR → maintainer adds **`plan-approved`** on **#31**; remove **`plan-needed`** if present.
2. `docs-maintainer` (or human) opens **implementation PR** executing sub-phases A–G (one PR preferred).
3. Close duplicate issues **#12**, **#23**, **#26** pointing at #31; use **#29** for verifier reconciliation ack.
4. Post-merge: `plan-verifier` pass; no `swarm-gap-ingest` (doc-only).

## Human-only

- [ ] Label **`plan-approved`** on #31 before doc implementation agents run.
- [ ] Approve duplicate-issue consolidation (#12, #23, #26 → #31).
- [ ] Merge implementation PR (agents do not self-merge governance docs).
