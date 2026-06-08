# Phase 2e: Contracts, refinements, VC generation

> **For agentic workers:** Use `.cursor/skills/build-li-master-plan/SKILL.md` — update [provability-gaps](../../verification/provability-gaps.md) **G-vc** in the same PR.

**Goal:** Emit typed proof obligations from `requires` / `ensures` / refinements; wire MIR witnesses; reject weak contracts at compile time.

**Architecture:** `vc_emit_lean.cpp` + `compiler/verify/vc_witness.cpp` → `build/generated/AutoVC.lean`; `lic verify` reports VC inventory + MIR linkage.

**Depends on:** Phase 2d (typecheck + borrow)  
**Blocks:** Phase 2f (Lean discharge), Phase H (httpd proof path)

**Proof gap (Doc-c):** [G-vc](../../verification/provability-gaps.md) · [G-bnd](../../verification/provability-gaps.md) · [G-narrow](../../verification/provability-gaps.md)

**Related:** [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md) · [contracts-and-proofs](../../language/contracts-and-proofs.md)

---

## Scope (closed slice vs v2 backlog)

| In scope (Phase 2e **closed slice**) | Out of scope (tracked under **G-vc** / **2f**) |
|--------------------------------------|--------------------------------------------------|
| Real `Prop` emission (not bare `True` stubs) for corpus specimens | Universal Lean kernel discharge on every `lic build` |
| Call-site callee `requires` (**E0304**) | Opaque float `vec3_dot`-style `ensures` |
| Refinement types + index guards (**E0305**) | Loop implementation vs closed-form `ensures` mismatch |
| Const-local / trivial discharge witnesses | Full method/trait `ensures` sugar (**2j-f**) |
| `lic verify` MIR linkage counters | `--strict-lean` on all user programs |

---

## Deliverables (shipped)

| Area | Implementation | Evidence |
|------|----------------|----------|
| AutoVC emission | Every `lic build` writes `build/generated/AutoVC.lean` | `scripts/ci.sh` “generate AutoVC (2e)” |
| Typed requires/ensures | `vc_*` defs carry real Props | `li-tests/tooling/vc_emit_contracts.sh` |
| MIR witnessed ensures | Return expr linked to callee `ensures` | `li-tests/tooling/mir_vc_witness.sh`, `compiler/verify/vc_witness.cpp` |
| Call-site requires | Callee preconditions at call | `discharge_caller_requires_*.sh`, `caller_requires_*.li` |
| Negative contracts | **E0303** / **E0304** / **E0305** | `li-tests/prove_reject/`, `contracts_verify/*_fail.li` |
| Open-goal inventory | Prop goals without `_proved` theorem | `scripts/check-autovc-open-goals.sh` (strict on closed corpus) |

---

## Phase 2e exit gate (CI)

Run on every PR (consolidated):

```bash
./scripts/check-phase-2e-gates.sh
```

**Must be green:**

| Gate | Script / artifact | Proves |
|------|-------------------|--------|
| **2e-a** AutoVC typed Props | `li-tests/tooling/vc_emit_contracts.sh` | `requires`/`ensures` lower to real Lean Props on `sqrt_contract.li` |
| **2e-b** MIR VC witness | `li-tests/tooling/mir_vc_witness.sh` | `lic verify` prints `witnessed_ensures=` + `mir_return_linked=` |
| **2e-c** Witness lowering | `compiler/verify/vc_witness.cpp` (built into `lic`) | C++ witness hooks for const-return / call-site discharge |
| **2e-d** Closed corpus discharge | `li-tests/tooling/contracts_discharge_corpus.sh` | Trivial/const/caller-requires/linalg closed slice → zero open goals |
| **2e-e** Open-goal checker | `scripts/check-autovc-open-goals.sh` | Fails when closed corpus leaves open `Prop` goals |
| **2e-f** Manifest smoke | `./li-tests/run_all.sh contracts_verify` | `prove_lean_ok` / `verify_ok` / `verify_open_ok` rows honest |
| **2e-g** Weak contract reject | `prove_reject/weak_ensures_true.li` | **E0303** — `ensures true` rejected |

**Wired in:** `scripts/ci.sh` (2e gate phase), `scripts/check-master-plan-gates.sh` (monorepo v1).

**Intentionally open (not 2e exit):** float opaque returns, loop-vs-spec ensures — see [provability-gaps § G-vc](../../verification/provability-gaps.md) and Phase **2f**.

---

## Phase 2e exit gate (checkbox)

Phase **2e** is **partial complete** when all **2e-a … 2e-g** rows above are green in CI. Full **G-vc Done** waits on Phase **2f** (Lean kernel closes remaining open VCs).

- [x] **2e-a** — `vc_emit_contracts.sh`
- [x] **2e-b** — `mir_vc_witness.sh` (`witnessed_ensures=`, `mir_return_linked=`)
- [x] **2e-c** — `vc_witness.cpp` witness hooks in `lic` binary
- [x] **2e-d** — `contracts_discharge_corpus.sh` (closed slice)
- [x] **2e-e** — `check-autovc-open-goals.sh` on closed corpus
- [x] **2e-f** — `run_all.sh contracts_verify`
- [x] **2e-g** — **E0303** weak ensures reject

**Still open (G-vc v2):** opaque float `ensures`, loop implementation vs spec — not blockers for marking Phase 2e closed-slice exit gates.

---

## Agent checklist

1. Run `./scripts/check-phase-2e-gates.sh` before claiming 2e work done.
2. Inspect `build/generated/AutoVC.lean` for `Prop :=` lines that are not `True` and lack `_proved`.
3. Update **G-vc** + master plan tracker in the **same PR** when adding specimens or moving status.
