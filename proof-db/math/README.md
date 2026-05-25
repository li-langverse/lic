# proof-db/math

Classical math vertical for the Li proof database.

| Area | Path | Catalog ids |
|------|------|-------------|
| Peano + order axioms | [axioms/peano_order.li](axioms/peano_order.li) | `M-AX-PEANO-*`, `M-AX-ORDER-*` |
| ℝ field axioms | [axioms/reals_field.li](axioms/reals_field.li) | `M-AX-REAL-*` |
| Lean stub module | [axioms/MathAxioms.lean](axioms/MathAxioms.lean) | `Li.ProofDb.Math.*` |
| Lemma specimens | [lemmas/](lemmas/) | `M-LM-*` |

**TOML source of truth:** `docs/verification/proof-database/entries/math-*.toml`.

```bash
python3 scripts/proof-db/proof-db.py list --field math
python3 scripts/proof-db/proof-db.py verify-slice
```
