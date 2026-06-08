# Phase 2e: Contracts, refinements, VC generation

> **For agentic workers:** REQUIRED SUB-SKILL: Use `.cursor/skills/build-li-master-plan/SKILL.md` — run exit gates via `scripts/check-phase-2e-gates.sh` before checking the master-plan tracker row.

**Goal:** Lower `requires` / `ensures` / `decreases` / refinement types to typed Lean `Prop` obligations in `build/generated/AutoVC.lean`; link MIR return expressions to `ensures` witnesses where statically known.

**Architecture:** `compiler/verify/` (`vc_emit`, `vc_witness.cpp`, `call_requires.cpp`) emits AutoVC; `lic verify` reports witness telemetry; `scripts/check-autovc-open-goals.sh` is the strict open-goals checker (wired in **2f**, required here for typed Props).

**Depends on:** Phase **2d** (borrow + effects)  
**Blocks:** Phase **2f** (Lean kernel discharge), **2j-f** (method VCs)

**Proof gaps (Doc-c):** [G-vc](../../verification/provability-gaps.md#g-vc) · [G-bnd](../../verification/provability-gaps.md#g-bnd) · [G-narrow](../../verification/provability-gaps.md#g-narrow)

**Related corpus:** [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md)

---

## Scope (v1 closed slice)

| Area | Shipped | Still open (v2 / **2f**) |
|------|---------|---------------------------|
| Call-site `requires` | **E0304** on bad literal args | Dynamic / non-literal args |
| Refinement types | **E0305** on bad init/call | Real refinement Props (not `True` stubs) |
| AutoVC emit | Typed `Prop` per clause on every `lic build` | Universal kernel discharge |
| MIR `ensures` witness | `witnessed_ensures` + `mir_return_linked` telemetry | Opaque returns (`vec3_dot`, float `abs`, …) |
| Policy rejects | **E0303** `ensures true`; extern without contracts | Full float / loop corpus |

---

## CI exit gate (Phase 2e v1 — must be green)

Run the aggregator (same gates as `scripts/check-master-plan-gates.sh` § VC tooling):

```bash
./scripts/check-phase-2e-gates.sh
```

| # | Gate | Command / artifact | Proves |
|---|------|-------------------|--------|
| 1 | AutoVC on build | `lic build` → `build/generated/AutoVC.lean` | Every build emits typed VC module |
| 2 | Real Props (not stubs) | `li-tests/tooling/vc_emit_contracts.sh` | `sqrt_contract.li` lowers `requires`/`ensures` to real Props |
| 3 | MIR witness telemetry | `li-tests/tooling/mir_vc_witness.sh` | `lic verify` prints `witnessed_ensures=` and `mir_return_linked=` |
| 4 | Witness implementation | `compiler/verify/vc_witness.cpp` | `compute_vc_witness_stats`, `witness_*` return/const linkage |
| 5 | Open goals checker | `scripts/check-autovc-open-goals.sh` | No unproved `vc_*` Prop without `_proved` theorem (strict build) |
| 6 | Discharge corpus | `li-tests/tooling/contracts_discharge_corpus.sh` | Closed specimens → zero open goals; intentional open probe for `sqrt_open_bound` |
| 7 | Manifest | `./li-tests/run_all.sh contracts_verify prove_reject` | `verify_ok` / `prove_lean_ok` / `compile_fail` (+ **E0303** / **E0304** / **E0305**) |

**Wired in CI:** `scripts/ci.sh` (open-goals on greeter smoke), `scripts/check-master-plan-gates.sh` (rows 2–6 above).

---

## Phase 2e v1 exit checklist

- [x] Call-site `requires` — **E0304** (`caller_requires_fail.li`)
- [x] Refinement types — **E0305** (`refinement_call_fail.li`, `refinement_init_fail.li`)
- [x] Weak `ensures true` rejected — **E0303** (`prove_reject/weak_ensures_true.li`)
- [x] Typed `AutoVC.lean` on every `lic build`
- [x] `lic verify` reports `witnessed_ensures=` + `mir_return_linked=`
- [x] `check-autovc-open-goals.sh` strict gate (no silent open Props)
- [x] `contracts_discharge_corpus.sh` green on closed slice
- [ ] **G-vc Done** — float `abs`, opaque `vec3_dot`-style returns, loop vs closed-form `ensures` (**2f** / **P-float**, **P-ensures-witness**)

---

## Explicit non-goals (2e v1)

| Item | Tracked in |
|------|------------|
| Lean kernel discharge on every `lic build` | **2f** / **G-lean** |
| Method/trait `ensures` sugar | **2j-f** |
| Full refinement Props | **P-refine** |
| Universal float ensures | **P-float** |

---

## Compiler / gap mapping

| Gap ID | After 2e v1 gate |
|--------|------------------|
| **G-vc** | **Partial** — closed slice CI green; opaque/float/loop VCs remain |
| **G-bnd** | Unchanged — release bounds path is **3** / `check_release_bounds_ir.sh` |
| **G-narrow** | Policy `cast[` reject only — width proofs deferred |

When **G-vc** moves toward **Done**, update [provability-gaps.md](../../verification/provability-gaps.md) in the **same PR** as the compiler change.
