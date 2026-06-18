# Doc-c: G-* exit gates for phase 03 and 07

> **Issue:** [#12](https://github.com/li-langverse/lic/issues/12) · **Umbrella:** [#31](https://github.com/li-langverse/lic/issues/31) · **Contradiction tracker:** [#29](https://github.com/li-langverse/lic/issues/29)  
> **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest gap linkage) → **Easy** (agents discover G-* from phase exit gates)  
> **north_star_fit:** Documentation / provability honesty · **PH-Doc-c** · **G-bnd**, **G-par**, **G-dec**, **G-math**  
> **Learned from:** [master plan § Doc-c](2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting), [provability-gaps.md](../../verification/provability-gaps.md), [Doc-c umbrella plan](2026-06-07-doc-c-g-star-phase-exit-gates.md) (#31 / PR #1081), [ph7e-tier1-red-benchmark-honesty](2026-05-30-ph7e-tier1-red-benchmark-honesty.md)

## Goal

Close the **#12** slice of master-plan **Doc-c** debt: phase plans **03** and **07** must cite applicable **G-*** register IDs at the **proof-gap line** and in **exit gate** bullets (7a–7e for phase 07), and the master plan must stop claiming Doc-c is done while 03/07 exit gates lack explicit G-* linkage.

This plan is the **scoped implementation slice** for #12. Full Doc-c scope (phase 02, spec stubs, `plan-cross-links.md`) remains on [#31](https://github.com/li-langverse/lic/issues/31) / [2026-06-07-doc-c-g-star-phase-exit-gates.md](2026-06-07-doc-c-g-star-phase-exit-gates.md).

## Problem (current state on `main`)

| Acceptance (#12) | Status on `main` |
|------------------|------------------|
| Phase 03 proof-gap line cites **G-bnd** | **Partial** — line exists at file bottom (`G-bnd`, `G-meta`) but not in header; not mirrored in exit bullets |
| Phase 03 exit gates cite **G-bnd** | **Missing** — `### Phase 3 exit gate` bullets name IR bounds checks without **G-bnd** anchor |
| Phase 07 proof-gap line cites **G-par**, **G-dec**, **G-math** | **Partial** — header bullet present; sub-gates 7a–7e mix informal mentions and missing IDs |
| Phase 07 exit gates (7a–7e) cite **G-par**, **G-dec**, **G-math** | **Missing** — exit section lists CI commands; only 7d-c and 7e table mention G-* inline |
| Master plan Doc-c reconciliation | **Contradictory** — checklist line 387 `[x]` vs tracker line 473 “expand to 03/07 as those land” ([#29](https://github.com/li-langverse/lic/issues/29)) |

**Plan-verifier evidence (2026-05-17):** phase 02 satisfies Doc-c header pattern; phases 03 and 07 do not satisfy exit-gate acceptance.

## Non-goals

- Closing any **G-*** row to **Done** (documentation cross-link only).
- Compiler, Lean, MIR, or `trusted.lean` changes.
- Weakening benchmark thresholds or claiming proof from doc edits.
- Replacing the #31 umbrella plan — execute A–G there for full Doc-c closure.

## Dependencies

- Living register: [`docs/verification/provability-gaps.md`](../../verification/provability-gaps.md).
- Umbrella plan: [2026-06-07-doc-c-g-star-phase-exit-gates.md](2026-06-07-doc-c-g-star-phase-exit-gates.md) (sub-phases A, C, D, G overlap #12).
- `docs-maintainer` lane after **`plan-approved`** on #12 (or inherited from #31).

## G-* inventory (scoped)

### Phase 03 — [`2026-05-14-phase-03-mir-codegen.md`](2026-05-14-phase-03-mir-codegen.md)

| G-* ID | Applicability | Exit-gate evidence (today) | Required edit |
|--------|---------------|------------------------------|---------------|
| **G-bnd** | **Yes** | `panic_if_oob`, `check_release_bounds_ir.sh` | Cite in proof-gap line (header) **and** each bounds-related exit bullet |
| **G-vc** | **Partial cite** | MIR preserves contract sites | Optional one-line in exit table — primary owner is phase 02/2e |
| **G-meta** | **N/A** | — | Keep N/A rationale (compiler-correctness research limit) |
| **G-dec**, **G-par**, **G-math** | **N/A** | — | Phase 7 surfaces |

### Phase 07 — [`2026-05-14-phase-07-native-hpc.md`](2026-05-14-phase-07-native-hpc.md)

| G-* ID | Sub-gate | Exit-gate evidence (today) | Required edit |
|--------|----------|------------------------------|---------------|
| **G-par** | **7b**, **7d-c** | `race_shared_memory/`, `good_disjoint_parallel.li`, `disjoint=` partial | Exit bullets + 7b/7d table rows |
| **G-dec** | **7d** | `decorators/`, `decorator_exploits/` | Exit bullets + 7d table rows |
| **G-math** | **7e** | `math_linalg/`, tier-1 advisory benches | Exit bullets + 7e table; cross-link [ph7e plan](2026-05-30-ph7e-tier1-red-benchmark-honesty.md) |
| **G-gpu** | **7d / wave-13** | `ml_gpu_device_buffer.li` | Optional cite — not in #12 acceptance |
| **G-lean** | **7e / 2f** | P-linalg open | **Partial cite** only — closure is PH-2f |

## Sub-phases (implementation — after `plan-approved`)

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Master plan reconcile** — narrow checklist **Doc-c** text to “phase 02/03/07 exit gates” **or** uncheck until B–C land; align sub-phase **Doc-c** row with spec-stub scope ([#29](https://github.com/li-langverse/lic/issues/29)) | Single definition; no `[x]` while 03/07 exit tables missing |
| **B** | **Phase 03** — move `Proof gaps (Doc-c):` to header (match phase 02); add `### Exit gate — G-* register` table; mirror **G-bnd** in `### Phase 3 exit gate` bullets | Every applicable row cited or N/A rationale |
| **C** | **Phase 07** — add `### Exit gate — G-* register` consolidating 7a–7e; annotate 7a–7c, 7d, 7e exit bullets with **G-par** / **G-dec** / **G-math** | Matches #12 acceptance verbatim |
| **D** | **Verifier ack** — comment on #29 that contradiction cleared; recommend close #12 → #31 duplicate cluster after merge | `plan-verifier` pass |

## Tests / verification

| Check | Command / review |
|-------|------------------|
| G-* anchors resolve | Manual: each `#g-bnd`, `#g-par`, `#g-dec`, `#g-math` opens register row |
| Phase 03 header + exit | `grep -n 'G-bnd' docs/superpowers/plans/2026-05-14-phase-03-mir-codegen.md` — ≥2 hits (header + exit) |
| Phase 07 exit coverage | `grep -nE 'G-par|G-dec|G-math' docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md` — present in exit gate section |
| Doc claim guard (optional) | `./scripts/check-doc-provability-claims.sh` on changed docs |
| Master plan honesty | Doc-c checkbox checked only in same PR as B–C |

## Provability

| Gap | Action |
|-----|--------|
| **G-bnd**, **G-par**, **G-dec**, **G-math** | **No status change** — cross-links only; rows stay Partial/Stub/Missing |
| **G-meta**, **G-lean** | Explicit **N/A** or **partial cite** where master plan lists as limits |

## Rollout

1. Merge this plan PR → maintainer adds **`plan-approved`** on **#12** (or confirms #31 approval covers #12); remove **`plan-needed`** if present.
2. `docs-maintainer` opens **implementation PR** executing sub-phases A–C (may combine with #31 sub-phases B–G in one docs PR).
3. Close **#12** as duplicate of **#31** after implementation lands, or keep #12 open until B–C verified.
4. Post-merge: `plan-verifier` on #29; no `swarm-gap-ingest` (doc-only).

## Human-only

- [ ] Label **`plan-approved`** on #12 before doc implementation agents run (or explicit maintainer ack that #31 approval suffices).
- [ ] Approve duplicate-issue consolidation (#12 → #31).
- [ ] Merge implementation PR (agents do not self-merge governance docs).
