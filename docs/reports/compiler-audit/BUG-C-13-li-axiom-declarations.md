# BUG-C-13 — Li axiom declarations & VC emit (RFC for Julian)

**Status:** **Partial** (`proof_db_*` discharge + `implies` in contracts; no `axiom proc` surface)  
**Gap kind:** G-vc / proof-db axiom layer  
**Related:** Phase 10 `proof-explorer-phase10-axiom-layer`, `proof-db/math/axioms/*.li`

## Problem

Proof-db math axioms exist as Lean `axiom` declarations (`MathAxioms.lean`) and Li **contract specimens** (`proof_db_*` defs). The compiler treats specimens as ordinary `def` bodies: VC emission may generate trivial witnesses (`ensures result == 0`) instead of:

1. Recognizing **axiom-role** definitions in proof-db only.
2. Emitting a **Lean theorem reference** (`lean_thm` from catalog) and **skipping** executable body VC.
3. Allowing **lemma discharge** to cite axioms by symbol.

Today agents work around missing `implies` with `not … or …`; that workaround is removed now that the parser accepts `implies` in `requires` / `ensures`.

## Policy (proof-db and ecosystem)

| Allowed | Forbidden |
|---------|-----------|
| `def proof_db_*` specimens with `requires` / `ensures` (use **`implies`** for implications) | `axiom proc`, bare `proc`, or `async proc` in proof-db |
| Catalog `kind = axiom` + `lean_thm` metadata | Executable axiom bodies beyond witness stubs |
| Lean discharge via `Li.Discharge.proof_db_*` / `MathAxioms.lean` | New axioms in `docs/semantics/trusted.lean` |

**Axiom layer shape:** ordinary Li **`def`** + catalog **`kind=axiom`** + **`lean_thm`** discharge in Lean — **not** a separate `axiom proc` AST node.

### Example (target)

```li
def proof_db_peano_succ_injective(a: int, b: int) -> int
  requires a >= 0 and b >= 0
  ensures ((a + 1) == (b + 1)) implies (a == b)
  decreases 0
=
  return 0
```

Catalog row (TOML): `kind = "axiom"`, `li_axiom_symbol`, `lean_thm = "Li.ProofDb.Math.peano_succ_injective"`, `specimen_role = "axiom"`.

## `vc_emit_lean` behavior (target)

| Case | Emit | Body VC |
|------|------|---------|
| Ordinary `def` | Current pipeline | Yes |
| `proof_db_*` axiom def (catalog + `is_proof_db_axiom_decl`) | `Li.Discharge.proof_db_*` / `lean_thm` cite | **Skip** trivial body witness |
| Lemma with `discharged_from` | Current + axiom cite list | Uses Discharge graph |

### Pseudocode hook

```
if decl.is_proof_db_axiom() && decl.lean_thm_from_catalog():
  emit_axiom_reference(lean_thm);
  return; // skip ensure_body_vc
```

## Lemma discharge

- `Discharge.lean` / AutoVC: allow edges `lemma → axiom` when catalog `statement` references `M-AX-*`.
- Gap scripts: `li-tests/tooling/axiom_decl_vc_skip_gap.sh` (expect PASS for discharged rows).

## Non-goals (this RFC)

- No axioms in `docs/semantics/trusted.lean`.
- No global `axiom` in user `main.li` without opt-in module flag.
- No `axiom proc` / `@axiom def` parser surface (superseded by def + catalog policy).

## Verification (post-implementation)

```bash
bash li-tests/tooling/axiom_decl_vc_skip_gap.sh   # PASS — proof_db_* Discharge cite
lic parse proof-db/math/axioms/peano_succ_injective.li
lic build proof-db/math/axioms/peano_succ_injective.li --no-lean-verify
bash scripts/check-li-def-syntax.sh proof-db
```

### Landed

- `is_proof_db_axiom_decl` in `vc_witness.cpp` — skips trivial `True` ensures for `proof_db_*` defs.
- `vc_emit_lean.cpp` — emits `Li.Discharge.proof_db_*_ensures_N_proved` (requires→ensures when present).
- `Discharge.lean` — `Li.ProofDb.Math.*` axioms + peano_succ_injective / order_antisym discharge.
- Parser: **`implies`** in contract expressions (`compiler/parser/parser.cpp`, `compiler/lexer/lexer.cpp`).
- Li specimens: Peano/order axioms use `implies` (not `not … or …`).

### Still Julian-owned

- Full float ℝ axiom discharge (currently `sorry` in Discharge).
- peano_zero / peano_induction stub ensures vs authoritative Prop statements.
- Catalog-driven `lean_thm` hook in `vc_emit_lean` without hard-coded discharge names.

## References

- `proof-db/math/axioms/MathAxioms.lean`
- `docs/verification/proof-database/entries/math-axioms.toml`
- `docs/superpowers/plans/proof-explorer-phase10-axiom-layer.md`
