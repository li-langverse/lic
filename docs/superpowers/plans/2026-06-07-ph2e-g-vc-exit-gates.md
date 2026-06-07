# PH-2e / G-vc: contracts, refinements, open-goals exit gates

> **Issue:** [#21](https://github.com/li-langverse/lic/issues/21) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first — Phase **2e** must cite shell corpora and gap-register evidence, not narrative-only tracker edits  
> **North star fit:** compiler verification, scientific computing — **PH-2e**, **G-vc**  
> **Umbrella:** [#32](https://github.com/li-langverse/lic/issues/32) sub-phase **E** (Lean/VC evidence closure)  
> **Learned from:** [master plan §2e](2026-05-14-li-master-plan.md), [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md), [provability-gaps §G-vc](../../verification/provability-gaps.md), [contracts-and-proofs](../../language/contracts-and-proofs.md)

## Goal

Define auditable **exit gates** for Phase **2e** (VC generation / contracts / refinements) so agents and humans can tell when **G-vc** moves from one honest **Partial** slice to the next — without silently widening CI gates or weakening `threshold_ratio_cpp`.

Each closure PR must cite the same shell corpora the gap register lists under **How we know** (`vc_emit_contracts.sh`, `mir_vc_witness.sh`, `contracts_discharge_corpus.sh`, `discharge_caller_requires_*.sh`).

## Problem

| Source | Claim today | Gap |
|--------|-------------|-----|
| Master plan tracker ~L454 | Phase **2e** checked **merged (PR #83)**; float/nontrivial ensures **still open** | No explicit checklist of which scripts must pass for “2e surface done” vs “G-vc slice closed” |
| Gap register **G-vc** | **Partial** — closed: call-site `requires`, const-local, E0303–E0305; open: opaque returns, loop vs closed-form `ensures` | “How we know” lists scripts but not pass/fail matrix per open class |
| `lic verify` | Prints `witnessed_ensures=` + `mir_return_linked=` | `mir_vc_witness.sh` covers const-return slice only; opaque / loop witnesses untested in CI matrix |
| `check-autovc-open-goals.sh` | Fails build on open Prop goals | Owned by **2f / G-lean** ([#17](https://github.com/li-langverse/lic/issues/17)); **2e** must document which open goals are **intentional** vs **regressions** |
| `vc_witness.cpp` | MIR-linked return witnesses for const / shape-matched ensures | No corpus row mapping each witness class → specimen → script |

**Root cause:** Phase **2e** merged compiler surface (PR #83) without a standalone phase doc listing **Definition of done** bullets tied to named CI commands. Tracker checkbox text and **G-vc** row drift from corpus reality.

## Non-goals

- Marking **G-vc** **Done** — universal VC discharge (opaque returns, all loop invariants) remains research (**P-ensures-witness**, **P-refine**, **P-loop**).
- Default `--strict-lean` on every `lic build` — tracked under **PH-2f / G-lean** ([#17](https://github.com/li-langverse/lic/issues/17)).
- Editing `trusted.lean` without a human-approved issue (swarm mandate).
- Weakening benchmark gates or `prove_reject/` policy to green-wash open VCs.
- Implementing compiler product code in the **plan** PR (docs-only).

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-2e** | VC generation — `requires`/`ensures`/refinements → `AutoVC.lean` |
| **G-vc** | Gap register row — source of truth for Partial slices |
| **G-lean** | Lean gate on open goals — sibling track [#17](https://github.com/li-langverse/lic/issues/17) |
| **G-test-verify** | Manifest honesty — `prove_lean_ok` vs `verify_open_ok` |
| **#32** | Umbrella Lean/VC evidence plan — this issue closes sub-phase **E** only |
| **P-refine** | Refinement types emit real Props (backlog) |
| **P-ensures-witness** | MIR-linked ensures for non-literal returns (backlog) |
| **P-float** | Float `abs` / sqrt bounds — `sqrt_open_bound` closed slice (trusted libm) |

## Phase 2e exit gates (Definition of done)

Phase **2e** has **three tiers**. Tracker checkbox and **G-vc** row must name the tier explicitly.

### Tier A — Surface merged (current baseline)

**Status:** **Done** (PR #83). Do not re-open unless regressions.

| Gate | Command / artifact | Must pass |
|------|-------------------|-----------|
| A1 | Call-site `requires` reject | `li-tests/contracts_verify/caller_requires_fail.li` → **E0304** |
| A2 | Refinement literal reject | `refinement_call_fail.li`, `refinement_init_fail.li` → **E0305** |
| A3 | Weak ensures reject | `prove_reject/weak_ensures_true.li` → **E0303** |
| A4 | Real Props in AutoVC | `./li-tests/tooling/vc_emit_contracts.sh` |
| A5 | Caller discharge corpus | `./li-tests/tooling/discharge_caller_requires_lean.sh`, `discharge_caller_requires_local_lean.sh` |
| A6 | Discharge orchestration | `./li-tests/tooling/contracts_discharge_corpus.sh` (closed slices; open probe tolerated) |

**Tracker text (proposed):**  
`Phase 2e — Contracts + refinements — **Tier A done (PR #83):** call-site requires (E0304), refinements (E0305), if-guard VC, import/extern; corpus [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md); **Tier B/C open — G-vc Partial**`

### Tier B — Witness telemetry (partial today)

**Status:** **Partial** — const-return MIR link proven in CI; opaque / loop witnesses documented open.

| Gate | Command / artifact | Must pass |
|------|-------------------|-----------|
| B1 | `lic verify` MIR link | `./li-tests/tooling/mir_vc_witness.sh` on `discharge_const.li` |
| B2 | Witness inventory | `lic verify` output includes `witnessed_ensures=` and `mir_return_linked=` for const-return specimens |
| B3 | C++ witness unit coverage | `compiler/verify/vc_witness.cpp` — document witness classes: const eval, shape-matched return, **open:** opaque call, loop body |

**Open (document, do not gate CI yet):**

- Opaque `vec3_dot`-style returns — `ensures` not MIR-linked (`P-ensures-witness`)
- Loop implementation vs closed-form `ensures` — `linalg_dot4_int_loop_open.li` closed under **2f**; general loop class open (`P-loop`)

**Tier B closure PR must:** add evidence matrix row (specimen → `lic verify` lines → pass/fail) to this plan or issue #21 comment; update **G-vc** “Still open” bullet to list only remaining classes.

### Tier C — G-vc honest Partial → next slice (future)

**Status:** **Not started** — requires new specimens + Lean lemmas; human approval for `trusted.lean` if needed.

| Slice | Corpus target | Exit when |
|-------|---------------|-----------|
| C1 **P-refine** | `refinement_*_ok.li` emit non-`True` Props | `discharge_refinement_lean.sh` + `check-autovc-open-goals.sh` green on refinement build |
| C2 **P-ensures-witness** | `use_positive.li`, physics smokes with MIR-linked ensures | New `mir_vc_witness_*.sh` rows; `witnessed_ensures` > 0 on opaque-return specimen |
| C3 **P-loop** | `loop_invariant_*.li` (new) | Loop invariant preservation in AutoVC + discharge script |

**G-vc** stays **Partial** until Tier C slices close or are explicitly deferred with issue links. **Done** requires universal discharge (out of **2e** scope; ties to **G-lean** kernel).

## Tests / verification (cite in every implementation PR)

| Check | Command | Gap / phase |
|-------|---------|-------------|
| VC emission | `./li-tests/tooling/vc_emit_contracts.sh` | **G-vc**, **PH-2e** Tier A |
| MIR witness telemetry | `./li-tests/tooling/mir_vc_witness.sh` | **G-vc**, **PH-2e** Tier B |
| Caller requires discharge | `./li-tests/tooling/discharge_caller_requires_lean.sh` | **G-vc** closed slice |
| Const-local discharge | `./li-tests/tooling/discharge_caller_requires_local_lean.sh` | **G-vc** closed slice |
| Corpus orchestration | `./li-tests/tooling/contracts_discharge_corpus.sh` | **G-lean**, **G-vc** |
| Open-goal inventory | `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` | **G-lean** / **2f** — cite intentional-open list from this plan |
| Manifest smoke | `./li-tests/run_all.sh contracts_verify` | **G-test-verify** |
| C++ witness | `compiler/verify/vc_witness.cpp` (unit / integration via verify path) | **PH-2e** Tier B |
| Doc claim guard | `./scripts/check-doc-provability-claims.sh` | Doc-c |

## Provability mapping

| ID | Action | Notes |
|----|--------|-------|
| **G-vc** | Stay **Partial**; update row when Tier B matrix lands | Closed: Tier A table. Open: Tier B “Open” bullets + Tier C backlog |
| **PH-2e** | Tracker **Tier A done / Tier B partial** | Do not check “Done” until Tier C policy agreed or deferred with issues |
| **G-lean** | No change in **2e** PRs except cross-links | Open goals policy = [#17](https://github.com/li-langverse/lic/issues/17) |
| **G-test-verify** | Reference `prove_lean_ok` / `verify_open_ok` split | Already **Done** |

## Implementation sub-phases (after `plan-approved`)

| Sub | Deliverable | Exit |
|-----|-------------|------|
| **1** | **Evidence matrix** — table: open VC class → specimen → script → pass/fail/intentional-open | Posted on #21; linked from master plan ~L454 |
| **2** | **Docs PR** — update master plan Phase **2e** checkbox to Tier A/B text; add Tier tables to this file; sync **G-vc** L37 + L86 “How we know” | `./scripts/check-doc-provability-claims.sh` green |
| **3** | **Optional follow-on** — Tier C specimen issues (**P-refine**, **P-ensures-witness**, **P-loop**) filed with `plan-needed` | One issue per slice; no bundled compiler work |

## Rollout

1. Merge this **plan** PR; human adds **`plan-approved`** on #21.
2. Post sub-phase **1** evidence matrix as issue comment (can be appendix in sub-phase **2** PR).
3. Sub-phase **2** docs-only PR — master plan + `provability-gaps.md` + cross-link from [phase-02-typechecker.md](2026-05-14-phase-02-typechecker.md) **Proof gaps** section.
4. Reference #32 umbrella when closing; do not duplicate #32 sub-phases B–D (G-lean) or F–G (G-math).
5. Close #21 when Tier B matrix is merged and tracker + **G-vc** rows cite it.

## Human-only

- [ ] Label **`plan-approved`** on #21 before sub-phase **2** implementer runs.
- [ ] Confirm Tier C deferrals vs active sprint — **P-refine** / **P-ensures-witness** may stay backlog.
- [ ] Approve any `trusted.lean` change via separate human issue.
- [ ] Do not conflate **2e** witness telemetry with **2f** default Lean gate ([#17](https://github.com/li-langverse/lic/issues/17)).
