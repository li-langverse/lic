# Phase 2e: Contracts, refinements, VC generation

> **For agentic workers:** Use `.cursor/skills/build-li-master-plan/SKILL.md` — update [provability-gaps](../../verification/provability-gaps.md) (**G-vc**) in the same PR.

**Goal:** Emit typed Lean proof obligations from `requires` / `ensures` / loop clauses; witness MIR-linked postconditions; reject weak or missing contracts at typecheck.

**Architecture:** `compiler/verify/vc_emit_lean.cpp` writes `build/generated/AutoVC.lean`; `compiler/verify/vc_witness.cpp` links return expressions to `ensures`; `scripts/check-autovc-open-goals.sh` scans for open Prop goals.

**Depends on:** Phase 2d (typecheck + borrow)  
**Blocks:** Phase 2f (Lean kernel discharge on every `lic build`)

**Proof gap (Doc-c):** [G-vc](../../verification/provability-gaps.md#g-vc)

**Related corpus:** [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md) · [contracts-and-proofs](../../language/contracts-and-proofs.md)

---

## Delivered (partial — PR #83+)

| Surface | Evidence |
|---------|----------|
| Call-site `requires` (**E0304**) | `discharge_caller_requires_lean.sh`, `caller_requires_ok.li` |
| Refinement types (**E0305**) | `index_refinement.li`, `discharge_refinement_lean.sh` |
| Weak `ensures true` reject (**E0303**) | `prove_reject/weak_ensures_true.li` |
| Typed AutoVC (not bare `True` stubs) | `vc_emit_contracts.sh` on `sqrt_contract.li` |
| MIR-linked `ensures` witnesses | `compiler/verify/vc_witness.cpp`; `mir_vc_witness.sh` (`witnessed_ensures=`, `mir_return_linked=`) |
| Open-goal inventory | `check-autovc-open-goals.sh` (wired in `contracts_discharge_corpus.sh`, `scripts/ci.sh`) |

---

## Phase 2e exit gate (partial — **G-vc** stays **Partial**)

CI and local review must green **`./scripts/check-phase-2e-exit-gates.sh`** (also invoked from `check-master-plan-gates.sh`). That script runs:

| Gate | Command / artifact | Proves |
|------|-------------------|--------|
| **VC emit** | `li-tests/tooling/vc_emit_contracts.sh` | `AutoVC.lean` carries real `Prop` for `requires`/`ensures` (not `Prop := True` stubs on contract specimens) |
| **MIR witness telemetry** | `li-tests/tooling/mir_vc_witness.sh` | `lic verify` reports `witnessed_ensures=` and `mir_return_linked=` for const-return discharge |
| **Discharge corpus** | `li-tests/tooling/contracts_discharge_corpus.sh` | Closed slices (trivial/const/caller-requires/linalg/refinement/bounds) → **zero open goals** via `check-autovc-open-goals.sh`; intentional open probe on `sqrt_open_bound.li` when still applicable |
| **Witness implementation** | `compiler/verify/vc_witness.cpp` | C++ witness helpers present (`collect_return_exprs_in_stmts`, const/local discharge paths used by corpus) |
| **Negative contracts** | `li-tests/run_all.sh prove_reject` (subset) | **E0303** / **E0304** / **E0305** rejections stay enforced |

**Master plan tracker:** Phase **2e** checkbox cites this partial gate. Full **G-vc → Done** is **not** claimed until opaque returns (`vec3_dot`-style), loop-vs-closed-form `ensures`, and remaining **P-float** / **P-ensures-witness** backlog close — tracked in [still open gaps](../../verification/provability-gaps.md#still-open-report-every-session).

---

## Phase 2e exit gate (full — future **G-vc → Done**)

Do **not** check this until every row is green without `--allow-open-vc`:

- [ ] All `contracts_verify` closed specimens on `prove_lean_ok` (no `verify_open_ok` drift)
- [ ] Opaque struct/CallProc `ensures` wired through `vc_witness.cpp` + `Discharge.lean` ( **P-ensures-witness**, **P-linalg** float Props)
- [ ] Loop implementations discharge against closed-form `ensures` without trusted stubs (**P-loop**)
- [ ] `lic build` default fails on any user-logic open VC (already **2f** overlap — keep registers aligned)

---

## Agent checklist

1. Run `./scripts/check-phase-2e-exit-gates.sh` after `cmake --build build` (or use `build-wsl/` binary via `resolve-lic.sh`).
2. Update **G-vc** in `provability-gaps.md` if status or closed slices move.
3. Cite **PH-2e** / **G-vc** in PR body; link this file under **Agent deliverable**.
