# Proof database — math vertical

**Schema:** [proof-database/schema.toml](proof-database/schema.toml) · **CLI:** `scripts/proof-db/proof-db.py`

Catalog for the **classical math** proof-db slice: Peano naturals, order lemmas, and ℝ field axioms pinned to Lean stubs in `proof-db/math/axioms/MathAxioms.lean`. Complements [provability gaps](provability-gaps.md) (`G-math`).

| Corpus | TOML slice | Rows |
|--------|------------|------|
| Axioms | [entries/math-axioms.toml](proof-database/entries/math-axioms.toml) | 9 × `M-AX-*`, `proof_status = axiomatic` |
| Lemmas | [entries/math-lemmas.toml](proof-database/entries/math-lemmas.toml) | 5 proved `M-LM-*` + 1 discrepancy (`M-LM-FLOAT-ADD-COMM`) |

**Release pin:** `2026-05-25` on all math rows.

## Commands

```bash
python3 scripts/proof-db/proof-db.py verify-slice
python3 scripts/proof-db/proof-db.py list --field math
```

## Discrepancies

Float vs real commutativity is tracked under [proof-db/math/discrepancy-policy.md](../proof-db/math/discrepancy-policy.md). `discrepancy` means catalog/specimen mismatch to triage — **not** “Li semantics are wrong.”

## Learned from

- **Lean mathlib** — stable theorem names + namespace layering
- **Coq stdlib** — axiom vs lemma catalog split
- **Dafny corpus** — `.li` specimens beside Lean stubs

## Agents

1. Read this hub + `proof-db/math/README.md`.
2. Run `verify-slice` before editing entries.
3. Keep `lean_module` paths resolvable from repo root; use `#` suffix only in docs, not in required `lean_module` field.
