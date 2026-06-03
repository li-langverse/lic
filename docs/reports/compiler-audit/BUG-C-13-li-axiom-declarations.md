# BUG-C-13 — Li axiom declarations & VC emit (RFC for Julian)

**Status:** **Open** (RFC — no agent `compiler/` edits in phase 10)  
**Gap kind:** G-vc / proof-db axiom layer  
**Related:** Phase 10 `proof-explorer-phase10-axiom-layer`, `proof-db/math/axioms/*.li`

## Problem

Proof-db math axioms exist as Lean `axiom` declarations (`MathAxioms.lean`) and Li **contract specimens** (`proof_db_*` defs). The compiler treats specimens as ordinary `def` bodies: VC emission may generate trivial witnesses (`ensures result == 0`) instead of:

1. Recognizing **axiom-role** definitions in proof-db only.
2. Emitting a **Lean theorem reference** (`lean_thm` from catalog) and **skipping** executable body VC.
3. Allowing **lemma discharge** to cite axioms by symbol.

Today agents work around this with statement-aligned `ensures` on `def` stubs; full honesty requires compiler support.

## Proposed surface (proof-db only)

### Option A — `axiom proc`

```li
axiom proc proof_db_peano_zero_not_succ()
  requires true
  ensures true   # Prop-level; no executable body
  lean_thm "Li.ProofDb.Math.peano_zero_not_succ"
```

- Parser: new `axiom proc` keyword scoped to `proof-db/**` (or `proof_status = axiomatic` modules).
- MIR: no body; mark symbol `AxiomDecl`.
- `vc_emit_lean`: emit `lean_thm` reference; **no** body VC obligation.

### Option B — `@axiom def`

```li
@axiom
def proof_db_peano_succ_injective(a: int, b: int) -> int
  requires a >= 0 and b >= 0
  ensures ((a + 1) == (b + 1)) implies (a == b)
```

- Attribute lowers to same `AxiomDecl` as Option A.
- `ensures` remain the Li-side contract mirror for the explorer.

## `vc_emit_lean` behavior (target)

| Case | Emit | Body VC |
|------|------|---------|
| Ordinary `def` | Current pipeline | Yes |
| `axiom proc` / `@axiom def` | `sorry` or axiom cite to `lean_thm` | **Skip** |
| Lemma with `discharged_from` | Current + axiom cite list | Uses Discharge graph |

### Pseudocode hook

```
if decl.is_axiom() && decl.lean_thm():
  emit_axiom_reference(decl.lean_thm());
  return; // skip ensure_body_vc
```

## Lemma discharge

- `Discharge.lean` / AutoVC: allow edges `lemma → axiom` when catalog `statement` references `M-AX-*`.
- Gap scripts: add `li-tests/tooling/axiom_decl_vc_skip_gap.sh` once implemented (expect PASS).

## Non-goals (this RFC)

- No axioms in `docs/semantics/trusted.lean`.
- No global `axiom` in user `main.li` without opt-in module flag.
- No change to phase 9 gap scripts until feature lands.

## Verification (post-implementation)

```bash
# Future — not run in phase 10 agent sprint
bash li-tests/tooling/axiom_decl_vc_skip_gap.sh
lic build proof-db/math/axioms/peano_zero_not_succ.li
```

## Agent policy

Phase 10 agents **must not** patch `compiler/verify/vc_emit_lean.cpp` or `vc_witness.cpp`. Update this RFC and catalog only until Julian approves implementation.

## References

- `proof-db/math/axioms/MathAxioms.lean`
- `docs/verification/proof-database/entries/math-axioms.toml`
- `docs/superpowers/plans/proof-explorer-phase10-axiom-layer.md`
