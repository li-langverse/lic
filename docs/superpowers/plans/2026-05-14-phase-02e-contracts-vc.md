# Phase 2e: Contracts + refinements + VC generation

**Goal:** Emit typed Lean `Prop` obligations from `requires` / `ensures` / loop clauses; witness MIR-linked ensures; discharge closed corpus slices.

**Architecture:** `vc_emit_lean.cpp` → `build/generated/AutoVC.lean`; `vc_witness.cpp` → `lic verify` telemetry; `check-autovc-open-goals.sh` → open-goal gate.

**Depends on:** Phase 2d (borrow + effects)  
**Blocks:** Phase 2f (Lean 4 kernel discharge)

**Proof gap:** [G-vc](../../verification/provability-gaps.md#g-vc) — **Partial** (this doc defines the **v1 exit gate**, not full G-vc closure)

**Related:** [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md) · [contracts-and-proofs](../../language/contracts-and-proofs.md)

---

## Exit gates (CI must be green)

| Gate | Command | Pass condition |
|------|---------|----------------|
| **2e-a** VC emit | `li-tests/tooling/vc_emit_contracts.sh` | `sqrt_contract.li` AutoVC has real `≥` Props, not bare `True` stubs |
| **2e-b** MIR witness | `li-tests/tooling/mir_vc_witness.sh` | `lic verify discharge_const.li` → `mir_fns=1 witnessed_ensures=1 mir_return_linked=1` |
| **2e-c** Discharge corpus | `li-tests/tooling/contracts_discharge_corpus.sh` | Closed specimens zero open goals; `sqrt_open_bound` open probe documented |
| **2e-d** Open goals | `scripts/check-autovc-open-goals.sh` | No open `def vc_* : Prop` on closed corpus builds |
| **2e-e** Manifest | `./li-tests/run_all.sh contracts_verify` | All manifest specimens green (`prove_lean_ok` / `verify_ok` / `verify_open_ok`) |
| **2e-f** Negative | `prove_reject/weak_ensures_true.li` | **E0303** reject (weak `ensures true`) |

**CI wiring:** `scripts/ci.sh` runs **2e-a** and **2e-b** under `lic verify smoke (2e/2f)`; **2e-c** when lake is installed; `scripts/check-master-plan-gates.sh` runs the full **2e-a…f** bundle.

**Evidence sources (gap register § How we know):**

- `compiler/verify/vc_witness.cpp` — static ensures witnesses, `compute_vc_witness_stats()`
- `li-tests/tooling/vc_emit_contracts.sh` — real Props in generated AutoVC
- `li-tests/tooling/mir_vc_witness.sh` — `witnessed_ensures=` + `mir_return_linked=` telemetry
- `li-tests/tooling/contracts_discharge_corpus.sh` — closed vs open discharge corpus

---

## Delivered on `dev` (PR #83 + follow-ups)

- Call-site `requires` discharge + **E0304** (`caller_requires_ok.li` / `caller_requires_fail.li`)
- Refinement types + **E0305** (`index_refinement.li`, `refinement_call_fail.li`)
- If-guard VC discharge; import/extern call-site contracts
- Typed `AutoVC.lean` emitted on every `lic build`
- `lic verify` prints `witnessed_ensures=` + `mir_return_linked=` + `mir_fns=`
- Open goals checker (`check-autovc-open-goals.sh`) fails on unproved `Prop` obligations

---

## Intentionally open (not 2e v1 gate)

These remain **G-vc Partial** — tracked separately (BUG-C backlog, **P-refine**, **P-ensures-witness**, **P-float**, **P-loop**):

| Topic | Specimen / script |
|-------|-------------------|
| Opaque `vec3_dot`-style FieldAccess ensures | `linalg_vec3_dot_float_opaque.li`, `vec3_dot_opaque_ensures_gap.sh` |
| Method `requires self.field >= arg` opaque in Lean | `method_call_requires_lean_gap.sh` |
| `sum(a*b)` vs `dot(a,b)` no Lean equivalence | `sum_dot_product_equiv_gap.sh` |
| Refinement call-site VCs stubbed `True` | **P-refine** backlog |
| Full float ensures beyond trusted slices | **P-float** partial |

**2e v1 gate complete** = rows **2e-a…f** green in CI. **G-vc Done** = all rows above closed (Phase 2f + compiler backlog).
