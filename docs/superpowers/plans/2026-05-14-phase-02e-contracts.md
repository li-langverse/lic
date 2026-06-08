# Phase 2e: Contracts + refinements — VC generation

> **For agentic workers:** REQUIRED SUB-SKILL: Use `build-li-master-plan` — update [provability-gaps.md](../../verification/provability-gaps.md) (**G-vc**) in the same PR.

**Goal:** Emit typed Lean proof obligations from `requires` / `ensures` / loop clauses; wire MIR-linked witness telemetry; gate CI on closed-corpus discharge.

**Architecture:** `compiler/verify/vc_emit_lean.cpp` lowers contract AST → `build/generated/AutoVC.lean`; `compiler/verify/vc_witness.cpp` links MIR return paths to witnessed `ensures`.

**Depends on:** Phase 2d (borrow + effects)  
**Blocks:** Phase 2f (Lean 4 in `lic build`), Phase H (httpd proof path)

**Proof gaps (Doc-c):** [G-vc](../../verification/provability-gaps.md#g-vc) · [G-bnd](../../verification/provability-gaps.md#g-bnd)

---

## Sub-phases & exit gates

| Sub | Task | Exit gate (must be green in CI) |
|-----|------|----------------------------------|
| **2e-a** | AutoVC emit on `lic build` | `lic build` writes `build/generated/AutoVC.lean` (`scripts/ci.sh` greeter smoke) |
| **2e-b** | Typed Props (not bare `True` stubs) | `li-tests/tooling/vc_emit_contracts.sh` — `sqrt_contract.li` emits real `requires`/`ensures` Props |
| **2e-c** | MIR-linked witness telemetry | `li-tests/tooling/mir_vc_witness.sh` — `lic verify` prints `witnessed_ensures=` + `mir_return_linked=` (`compiler/verify/vc_witness.cpp`) |
| **2e-d** | Call-site `requires` VCs | `discharge_caller_requires_lean.sh` + `discharge_caller_requires_local_lean.sh` (via `contracts_discharge_corpus.sh`) |
| **2e-e** | Refinement-type VCs | `discharge_refinement_lean.sh` + `index_refinement.li` build (`contracts_discharge_corpus.sh`) |
| **2e-f** | Open-goals checker (closed corpus) | `scripts/check-autovc-open-goals.sh` on discharged specimens; intentional open probe for `sqrt_open_bound.li` documented in corpus script |
| **2e-g** | Strict surface rejects | `li-tests/prove_reject/weak_ensures_true.li` (**E0303**); call-site requires violations (**E0304**); refinement violations (**E0305**) |

**Phase 2e v1 gate** = all rows **2e-a … 2e-g** green. **G-vc** remains **Partial** until float/opaque `ensures` and loop-vs-closed-form specs close (tracked in **2f** / [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md)).

---

## Implementation map

| Component | Path |
|-----------|------|
| VC emit (Lean) | `compiler/verify/vc_emit_lean.cpp` |
| MIR witness stats | `compiler/verify/vc_witness.cpp`, `compiler/verify/include/li/vc_witness.hpp` |
| `lic verify` telemetry | `compiler/lic/main.cpp` (`witnessed_ensures`, `mir_return_linked`) |
| Open-goals gate | `scripts/check-autovc-open-goals.sh` |
| Corpus runner | `li-tests/tooling/contracts_discharge_corpus.sh` |
| Master-plan aggregator | `scripts/check-master-plan-gates.sh` |

---

## Phase 2e exit gate (verification commands)

Run from repo root after `scripts/build.sh`:

```bash
export LIC="$(./scripts/resolve-lic.sh)"

# 2e-a: AutoVC emit
rm -f build/generated/AutoVC.lean
"$LIC" build li-tests/modules/greeter/greeter.li -o /dev/null
test -f build/generated/AutoVC.lean

# 2e-b … 2e-g: tooling smokes
chmod +x li-tests/tooling/vc_emit_contracts.sh \
  li-tests/tooling/mir_vc_witness.sh \
  li-tests/tooling/contracts_discharge_corpus.sh
./li-tests/tooling/vc_emit_contracts.sh
./li-tests/tooling/mir_vc_witness.sh
./li-tests/tooling/contracts_discharge_corpus.sh

# Manifest: contracts_verify + prove_reject
./li-tests/run_all.sh contracts_verify
./li-tests/run_all.sh prove_reject
```

**CI wiring:** `scripts/ci.sh` phases `generate AutoVC (2e)` and `lic verify smoke (2e/2f)`; full aggregator `scripts/check-master-plan-gates.sh`.

---

## Still open (not 2e v1 gate)

| Item | Gap / backlog | Evidence |
|------|---------------|----------|
| Float `abs` / `sqrt_open_bound` | **G-vc**, **P-float** | `sqrt_open_bound.li` — `--allow-open-vc` probe in corpus |
| Opaque `vec3_dot`-style returns | **G-vc**, **P-linalg** | `vec3_dot_opaque_ensures_gap.sh` |
| Loop impl vs closed-form `ensures` | **G-vc**, **P-loop** | `dot4_loop_ensures_lean_stub_gap.sh` |
| Method/trait VCs | **G-oop** | [OOP roadmap](2026-05-20-li-oop-roadmap.md) § 2j-f |

Close these in **2f** discharge PRs; do not widen 2e v1 gates silently.

---

## Documentation to update when gates move

| Doc | Action |
|-----|--------|
| [provability-gaps.md](../../verification/provability-gaps.md) | **G-vc** row + § Still open |
| [contracts-and-proofs.md](../../language/contracts-and-proofs.md) | Implementation status admonition |
| [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md) | Phase completion tracker row **2e** |
