# Phase 2e — Contracts + refinements (VC generation)

> **Depends on:** **2d** (borrow + effects)  
> **Blocks:** **2f** (Lean discharge in `lic build`), **2j-f** (method VCs), **G-vc** → **Done**  
> **Proof gap:** [G-vc](../../verification/provability-gaps.md#g-vc) · [G-bnd](../../verification/provability-gaps.md#g-bnd) (refinement slice)

**Goal:** Emit typed Lean proof obligations (`AutoVC.lean`) from `requires` / `ensures` / loop clauses; link MIR return shapes to witnessed ensures; fail CI when closed-corpus VCs stay open.

**North star fit:** Mathematical provability — contracts become checkable Props before kernel discharge (**2f**).

---

## Today (partial — v1 exit met)

| Feature | State | Evidence |
|---------|--------|----------|
| Typed `AutoVC.lean` on `lic build` | **Done** | `build/generated/AutoVC.lean`; `vc_emit_contracts.sh` |
| Real Props (not bare `True` stubs) | **Done** | `li-tests/contracts_verify/sqrt_contract.li` |
| Call-site callee `requires` (**E0304**) | **Done** | `discharge_caller_requires_lean.sh`, `caller_requires_ok.li` |
| Refinement types (**E0305**) | **Done** | `index_refinement.li`, `discharge_refinement_lean.sh` |
| `lic verify` MIR witness telemetry | **Done** | `witnessed_ensures=`, `mir_return_linked=` — `mir_vc_witness.sh`, `compiler/verify/vc_witness.cpp` |
| Open-goals checker (closed corpus) | **Done** | `check-autovc-open-goals.sh` via `contracts_discharge_corpus.sh` |
| Float `abs` / opaque returns / loop vs closed-form | **Open** | **P-float**, **P-linalg**, **P-ensures-witness** — see [still open](../../verification/provability-gaps.md#still-open-report-every-session) |

**Honest label:** **2e v1 = VC emit + witness linkage + closed-corpus open-goal gate**. Full **G-vc** → **Done** waits on **2f** + remaining **P-*** backlog.

---

## Sub-phases & exit gates

| Sub | Task | Exit gate (CI) |
|-----|------|----------------|
| **2e-a** | **VC emit** — `requires`/`ensures` lower to typed Props in `AutoVC.lean` | `./li-tests/tooling/vc_emit_contracts.sh` — **exit 0**; `vc_sqrt_pos_requires_0` not `:= True` |
| **2e-b** | **MIR witness** — `lic verify` reports `witnessed_ensures=` and `mir_return_linked=` | `./li-tests/tooling/mir_vc_witness.sh` — **exit 0**; implementation in `compiler/verify/vc_witness.cpp` |
| **2e-c** | **Open-goals checker** — closed `contracts_verify` corpus has no unproved Prop obligations | `./li-tests/tooling/contracts_discharge_corpus.sh` — **exit 0**; includes `check-autovc-open-goals.sh` on discharged specimens |
| **2e-d** | **Float / opaque / loop ensures** — discharge nontrivial `ensures` (vec3, loop dot vs closed form) | **Deferred** — tracked under **P-float**, **P-linalg**; `sqrt_open_bound` closed slice is **2f** + **G-lean** |

### Composite gate (master plan / CI)

```bash
./scripts/check-phase-2e-gates.sh   # runs 2e-a + 2e-b + 2e-c
```

Invoked from `scripts/check-master-plan-gates.sh`.

---

## Phase 2e v1 exit (checkbox — partial)

All of **2e-a**, **2e-b**, **2e-c** green:

- [x] **2e-a** — `vc_emit_contracts.sh`
- [x] **2e-b** — `mir_vc_witness.sh` + `vc_witness.cpp` witness counters
- [x] **2e-c** — `contracts_discharge_corpus.sh` + `check-autovc-open-goals.sh`

**G-vc** remains **Partial** until **2e-d** closes (**P-float**, opaque `vec3_dot`, loop implementations vs closed-form `ensures`). Do not widen default `lic build` gates silently.

---

## Phase 2e Done (future — **G-vc** → **Done**)

| Deliverable | Detail |
|-------------|--------|
| All tier-1 `contracts_verify` specimens | `prove_lean_ok` without `--allow-open-vc` on shipped paths |
| Opaque / CallProc ensures | `vec3_dot`, `vec3_len` chains wired in `vc_witness.cpp` + `Li.Discharge` |
| Loop vs closed-form | `dot4_int_loop_eval_spec` discharged or documented intentional open |
| Default `lic build` | Fails on any open Prop (no env bypass) — overlaps **2f** / **G-lean** |

**Exit:** **G-vc** row → **Done** in [provability-gaps.md](../../verification/provability-gaps.md); master plan tracker cites `prove_lean_ok` corpus count.

---

## Key files

| Path | Role |
|------|------|
| `compiler/verify/vc_emit_lean.cpp` | Lean Prop emission |
| `compiler/verify/vc_witness.cpp` | MIR return ↔ ensures witness linkage |
| `compiler/lic/main.cpp` | `lic verify` telemetry (`witnessed_ensures`, `mir_return_linked`) |
| `scripts/check-autovc-open-goals.sh` | Count open Prop obligations in `AutoVC.lean` |
| `li-tests/tooling/vc_emit_contracts.sh` | **2e-a** gate |
| `li-tests/tooling/mir_vc_witness.sh` | **2e-b** gate |
| `li-tests/tooling/contracts_discharge_corpus.sh` | **2e-c** gate |

**Related:** [proof-corpus-roadmap.md](../../verification/proof-corpus-roadmap.md) · [contracts-and-proofs.md](../../language/contracts-and-proofs.md)
