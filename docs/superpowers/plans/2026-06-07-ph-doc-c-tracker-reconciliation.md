# PH-Doc-c: master plan tracker reconciliation (Doc-c contradiction)

> **Issue:** [#29](https://github.com/li-langverse/lic/issues/29) (canonical for tracker bookkeeping) · **Implementation:** [#31](https://github.com/li-langverse/lic/issues/31) · **Related:** [#12](https://github.com/li-langverse/lic/issues/12), [#23](https://github.com/li-langverse/lic/issues/23), [#26](https://github.com/li-langverse/lic/issues/26)  
> **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest tracker state) → **Easy** (agents close checkboxes without ambiguity)  
> **north_star_fit:** Documentation / provability honesty (pillar 1) · **PH-Doc-c** · **G-*** register cross-links (no gap closure from docs alone)  
> **Learned from:** [master plan § Doc](2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting), [provability-gaps.md](../../verification/provability-gaps.md), [plan-cross-links.md](../../ecosystem/plan-cross-links.md), [2026-06-07-doc-c-g-star-phase-exit-gates.md](2026-06-07-doc-c-g-star-phase-exit-gates.md) (companion implementation plan on #31)

## Goal

Resolve the **Doc-c definition split** in `2026-05-14-li-master-plan.md` so plan-verifier and `docs-maintainer` agents can close tracker rows without contradictory signals. This plan scopes **bookkeeping reconciliation only**; phase-plan G-* exit-gate edits execute under [#31](https://github.com/li-langverse/lic/issues/31) sub-phases B–G.

## Problem (contradiction on `main`)

Two sections in the master plan use **Doc-c** for different work:

| Location | Doc-c meaning | Tracker state |
|----------|---------------|---------------|
| § *Phase Doc — sub-phases* (≈L343) | **Spec stubs** — decorator + math surface docs cite **G-*** | Sub-phase row text; no checklist |
| § *Documentation gaps to close* (≈L387) | **Phase exit gates** — plans 02 / 03 / 07 cite **G-*** at exit criteria | Marked `[x]` (premature) |

**Evidence gap:** Phase 02 has header-level `Proof gaps (Doc-c):` bullets; phases 03 and 07 lack explicit **G-*** tables at exit gates. Checklist `[x]` therefore disagrees with both the sub-phase table and verifier evidence.

**Blocker:** `plan-verifier` cannot honestly close Doc-c while definitions diverge and the checklist claims completion before phase 03/07 exit gates cite register IDs.

## Non-goals

- Closing any **G-*** row to **Done** (documentation cross-link only).
- Compiler, Lean, or `trusted.lean` changes.
- Duplicating [#31](https://github.com/li-langverse/lic/issues/31) phase-plan edit work in a separate PR (execute via #31 after both plans approved).
- Closing duplicate issues without maintainer ack.

## Dependencies

- Living register: [`docs/verification/provability-gaps.md`](../../verification/provability-gaps.md).
- Companion plan: [`2026-06-07-doc-c-g-star-phase-exit-gates.md`](2026-06-07-doc-c-g-star-phase-exit-gates.md) ([#31](https://github.com/li-langverse/lic/issues/31), PR [#1081](https://github.com/li-langverse/lic/pull/1081)).
- `docs-maintainer` lane after **`plan-approved`** on **#29** and **#31**.

## Reconciliation strategy (recommended)

Split the overloaded **Doc-c** label into two explicit sub-phases in the master plan:

| New ID | Scope | Checklist rule |
|--------|-------|----------------|
| **Doc-c₁** | Phase plans **02 / 03 / 07** — **Exit gate — G-* register** tables (or N/A rationale) | Unchecked until #31 sub-phases B–D land |
| **Doc-c₂** | **Spec stubs** — `2026-05-16-li-execution-decorators.md`, `2026-05-16-li-math-linalg-surface.md` cite **G-*** | Unchecked until #31 sub-phase E lands |

**Immediate fix (same PR as reconciliation):**

1. Replace single **Doc-c** sub-phase row with **Doc-c₁** + **Doc-c₂** rows in § *Phase Doc — sub-phases*.
2. Replace checklist bullet **Doc-c** with separate **Doc-c₁** and **Doc-c₂** items — both **unchecked** on `main`.
3. Add one-line cross-link: “See [Doc-c G-* phase exit gates plan](2026-06-07-doc-c-g-star-phase-exit-gates.md).”
4. Remove the premature `[x]` on the old combined Doc-c checklist row.

**Alternative (not recommended):** Retain single **Doc-c** and uncheck `[x]` only — still leaves sub-phase vs checklist semantic clash.

## Sub-phases (implementation — after `plan-approved`)

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **R-a** | Master plan § *Phase Doc* — split **Doc-c** → **Doc-c₁** / **Doc-c₂** with distinct exit gates | No single row mixes spec stubs and phase exit gates |
| **R-b** | Master plan § *Documentation gaps* — separate unchecked **Doc-c₁** / **Doc-c₂** bullets; delete contradictory `[x]` | Checklist matches sub-phase table |
| **R-c** | `plan-cross-links.md` — Doc-c row notes dual scope + links both plan docs | Agents discover mapping |
| **R-d** | Orchestrator handoff comment on **#29** when #31 implementation PR merges | `plan-verifier` ack |

Sub-phases **R-a–R-c** may land in the same PR as #31 sub-phases A–G, or in a short docs-only PR if maintainers prefer split delivery. **#29 closes when R-a–R-c merge and verifier confirms no contradictory Doc-c signals.**

## Tests / verification

| Check | Command / review |
|-------|------------------|
| No duplicate Doc-c definitions | Manual: master plan has **Doc-c₁** + **Doc-c₂** only |
| Checklist honesty | **Doc-c₁** / **Doc-c₂** unchecked until #31 work merges |
| G-* anchors (after #31) | Each linked `#g-*` opens register row |
| Plan-verifier | Re-run on **#29** — contradiction cleared |

## Provability

| Gap | Action |
|-----|--------|
| All **G-*** | **No status change** — tracker reconciliation only |
| **G-meta**, **G-hw**, **G-wrong-spec** | Unchanged — limits per master plan |

## Rollout

1. Merge this plan PR → maintainer adds **`plan-approved`** on **#29**; remove **`plan-needed`** if present.
2. Coordinate with **#31** (`plan-approved`, PR [#1081](https://github.com/li-langverse/lic/pull/1081)): implementation PR executes R-a–R-c plus #31 sub-phases A–G (one PR preferred).
3. `plan-verifier` pass → close **#29** with link to merged reconciliation.
4. Close duplicate cluster **#12**, **#23**, **#26** as duplicates of **#31** (maintainer ack).

## Human-only

- [ ] Label **`plan-approved`** on **#29** before docs agents edit master plan.
- [ ] Confirm **Doc-c₁** / **Doc-c₂** naming with maintainer (or approve alternate split).
- [ ] Merge reconciliation + implementation PR (agents do not self-merge governance docs).
