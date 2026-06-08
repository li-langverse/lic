# Phase 2e: Contracts, refinements, VC generation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Emit typed Lean VCs from `requires` / `ensures` / loop clauses; link MIR return paths to witnessed ensures; fail builds when closed-corpus Prop goals lack discharge theorems.

**Architecture:** `vc_emit_lean.cpp` lowers contracts to `build/generated/AutoVC.lean`; `vc_witness.cpp` records MIR-linked ensures telemetry consumed by `lic verify`.

**Tech Stack:** C++ compiler (`compiler/verify/`), Lean 4 AutoVC package (`docs/semantics/`)

**Depends on:** Phase 2d  
**Blocks:** Phase 2f

**Proof gaps (Doc-c):** [G-vc](../../verification/provability-gaps.md#g-vc) · [G-bnd](../../verification/provability-gaps.md#g-bnd)

---

## Compiler surface (v1 partial on `dev`)

| Area | Shipped | Diagnostics |
|------|---------|-------------|
| Call-site `requires` | Callee preconditions at call sites | **E0304** |
| Refinement types | Index / range refinements in types | **E0305** |
| if-guard discharge | Branch guards discharge VCs | — |
| import / extern | Callee contract inheritance | — |
| AutoVC emission | Every `lic build` writes typed Props | — |
| MIR ensures witness | `lic verify` telemetry | `witnessed_ensures=`, `mir_return_linked=` |
| Open-goals checker | Prop without `_proved` theorem → exit 1 | `check-autovc-open-goals.sh` |

**Evidence files:**

- `compiler/verify/vc_witness.cpp` — `compute_vc_witness_stats`, `witness_*` helpers (dot loop, mat2 `@`, vec3_len chain, sqrt bound, bounds read, callee-ensures inheritance)
- `compiler/verify/vc_emit_lean.cpp` — AutoVC lowering
- `scripts/check-autovc-open-goals.sh` — open Prop gate (2e checker; strict discharge in 2f)

---

## Still open (G-vc remains **Partial**)

Does **not** block the v1 exit gate below — tracked in [provability-gaps § G-vc](../../verification/provability-gaps.md#g-vc):

- Opaque float `vec3_dot`-style FieldAccess ensures
- Loop implementations vs closed-form `ensures` (e.g. `dot4_int_loop_eval_spec`)
- Universal kernel discharge for all user programs (**G-lean** / Phase 2f)

---

## Phase 2e v1 exit gate

**What must be green in CI** (also run locally after `./scripts/build.sh`):

| Gate | Command / hook | Pass means |
|------|----------------|------------|
| Typed AutoVC (no bare `True` stubs) | `./li-tests/tooling/vc_emit_contracts.sh` | `vc_sqrt_pos_requires_0` and ensures lower to real Props |
| MIR-linked ensures telemetry | `./li-tests/tooling/mir_vc_witness.sh` | `lic verify` prints `witnessed_ensures=1` and `mir_return_linked=1` on `discharge_const.li` |
| Closed corpus + open-goals checker | `./li-tests/tooling/contracts_discharge_corpus.sh` | Runs `discharge_*_lean.sh` smokes; `check-autovc-open-goals.sh` zero open on closed rows; `--allow-open-vc` probe for intentional open (`sqrt_open_bound`) |
| Manifest honesty | `./li-tests/run_all.sh contracts_verify` | `verify_ok` rows pass strict `lic build` |
| Master-plan aggregate | `./scripts/check-master-plan-gates.sh` | Invokes `vc_emit_contracts.sh`, `mir_vc_witness.sh`, `contracts_discharge_corpus.sh` |
| PR CI | `scripts/ci.sh` | Phases **generate AutoVC (2e)** and **lic verify smoke (2e/2f)** |

Checklist (v1 slice — **Partial** overall; do not widen to universal Lean certificate):

- [x] `./li-tests/tooling/vc_emit_contracts.sh` exit 0
- [x] `./li-tests/tooling/mir_vc_witness.sh` exit 0
- [x] `./li-tests/tooling/contracts_discharge_corpus.sh` exit 0 (includes `check-autovc-open-goals.sh` on closed corpus)
- [x] `./li-tests/run_all.sh contracts_verify` exit 0
- [x] `scripts/ci.sh` 2e / 2f verify phases exit 0
- [ ] Universal VC discharge for all programs — **deferred to Phase 2f / G-lean**

**Quick verify:**

```bash
export LI_REPO_ROOT="$PWD" LIC="${LIC:-./build/compiler/lic/lic}"
./li-tests/tooling/vc_emit_contracts.sh
./li-tests/tooling/mir_vc_witness.sh
./li-tests/tooling/contracts_discharge_corpus.sh
```
