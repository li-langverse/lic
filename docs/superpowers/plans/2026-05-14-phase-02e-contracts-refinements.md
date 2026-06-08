# Phase 2e: Contracts + refinements (VC generation)

> **Depends on:** **2d** (typecheck + borrow)  
> **Blocks:** **2f** (Lean discharge in `lic build`)  
> **Related gaps:** [G-vc](../../verification/provability-gaps.md#g-vc) · [G-bnd](../../verification/provability-gaps.md#g-bnd) · [G-narrow](../../verification/provability-gaps.md#g-narrow)

**Goal:** Every `requires` / `ensures` / loop clause lowers to typed Lean `Prop` obligations in `build/generated/AutoVC.lean`; call-site and refinement checks reject ill-formed programs at compile time; `lic verify` reports MIR-linked witness telemetry.

**North star fit:** PH-2e — proof-before-perf; no `Any`, `unsafe`, or silent `True` stubs for user-facing contracts.

---

## Today (v1 gate — green in CI)

| Feature | State | Evidence |
|---------|--------|----------|
| `AutoVC.lean` emit on every `lic build` | **Done** | `check-master-plan-gates.sh` VC emit phase |
| Typed `Prop` VCs (not bare `True` for real contracts) | **Done** | `li-tests/tooling/vc_emit_contracts.sh` |
| `lic verify` MIR witness telemetry | **Done** | `compiler/verify/vc_witness.cpp` → `witnessed_ensures=` + `mir_return_linked=`; `li-tests/tooling/mir_vc_witness.sh` |
| Call-site `requires` (**E0304**) | **Done** | `caller_requires_ok.li` / `caller_requires_fail.li` |
| Refinement types (**E0305**) | **Done** | `refinement_*_ok.li` / `refinement_*_fail.li` |
| Weak `ensures true` reject (**E0303**) | **Done** | `prove_reject/weak_ensures_true.li` |
| Closed discharge corpus (const, caller, linalg int) | **Done** | `li-tests/tooling/contracts_discharge_corpus.sh` |
| Open-goal checker on closed builds | **Done** | `scripts/check-autovc-open-goals.sh` (wired in `scripts/ci.sh` when lake present) |
| `contracts_verify` manifest suite | **Done** | `./li-tests/run_all.sh contracts_verify` |

**Honest label:** **2e v1 = VC generation + static gates**. Kernel discharge of all ensures is **Phase 2f** (**G-lean**). Float opaque returns and loop-vs-closed-form ensures remain **G-vc Partial**.

---

## Compiler surface

| Component | Role |
|-----------|------|
| `compiler/verify/vc_witness.cpp` | Shape-match return `ensures` to MIR; count `mir_return_linked` |
| `compiler/verify/vc_emit.cpp` | Write typed `def vc_* : Prop` into `AutoVC.lean` |
| `compiler/lic/main.cpp` | `lic verify` prints `mir_fns=`, `witnessed_ensures=`, `mir_return_linked=` |
| `scripts/check-autovc-open-goals.sh` | Fail when non-trivial `Prop` lacks `_proved` theorem |

---

## Phase 2e exit gate (v1 — must be green in CI)

These gates define **PH-2e v1 complete**. They do **not** claim **G-vc Done** (float / opaque / loop backlog stays in [provability-gaps](../../verification/provability-gaps.md#still-open-report-every-session)).

### Gate A — AutoVC emit

- [x] `lic build` writes `build/generated/AutoVC.lean` (any module with contracts)
- [x] `scripts/check-master-plan-gates.sh` VC emit phase passes

### Gate B — Real Props, not stubs

- [x] `./li-tests/tooling/vc_emit_contracts.sh` — `sqrt_contract.li` emits `≥` / `Float.abs`, not `Prop := True` for `requires`

### Gate C — MIR witness telemetry

- [x] `./li-tests/tooling/mir_vc_witness.sh` — `lic verify discharge_const.li` prints `mir_fns=1 witnessed_ensures=1 mir_return_linked=1`
- [x] Implementation: `compiler/verify/vc_witness.cpp` (`collect_return_exprs_in_stmts`, `mir_return_linked` counter)

### Gate D — Static contract enforcement

- [x] `./li-tests/run_all.sh contracts_verify` — positives + `prove_reject/weak_ensures_true.li` (**E0303**)
- [x] Call-site `requires` (**E0304**) and refinement (**E0305**) compile_fail specimens green

### Gate E — Closed discharge slice

- [x] `./li-tests/tooling/contracts_discharge_corpus.sh` — trivial/const/caller-requires/linalg-int/refinement builds; `check-autovc-open-goals.sh` on `index_refinement.li`; intentional open probe on `sqrt_open_bound.li`

### Gate F — Open goals checker (closed corpus only)

- [x] `scripts/check-autovc-open-goals.sh` in `scripts/ci.sh` (when lake installed) and `check-master-plan-gates.sh`

**CI entrypoints:** `scripts/ci.sh` (PR gate) · `scripts/check-master-plan-gates.sh` (local v1 sweep)

```bash
./li-tests/tooling/vc_emit_contracts.sh
./li-tests/tooling/mir_vc_witness.sh
./li-tests/tooling/contracts_discharge_corpus.sh
./li-tests/run_all.sh contracts_verify
```

---

## v2 backlog (keeps **G-vc Partial**)

| ID | Topic | Suggested next corpus |
|----|-------|----------------------|
| **P-float** | Float `abs`, non-sqrt ensures | Extend `sqrt_contract.li` lemmas beyond trusted libm |
| **P-ensures-witness** | Opaque / CallProc returns | `vec3_dot`, `vec3_len` gap scripts in `li-tests/tooling/` |
| **P-refine** | Refinement VCs as real Props | `refinement_*` + `Discharge.lean` |
| **P-loop** | Loop body vs closed-form `ensures` | Remaining open loop specimens |

**G-vc → Done** only when v2 rows close **and** `check-autovc-open-goals.sh` passes on the full `contracts_verify` closed corpus without `--allow-open-vc`. Track in **2f** / lic#17 for **G-lean**.

---

## Documentation cross-links

| Doc | Action |
|-----|--------|
| [provability-gaps.md](../../verification/provability-gaps.md) | **G-vc** row cites gates B–E above |
| [proof-corpus-roadmap.md](../../verification/proof-corpus-roadmap.md) | Corpus inventory + run commands |
| [contracts-and-proofs.md](../../language/contracts-and-proofs.md) | `lic build` vs Lean certificate honesty |
