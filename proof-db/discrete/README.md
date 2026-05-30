# proof-db/discrete

Discrete / integer algebra vertical for the Li proof database (**WP1**).

| Area | Path | Catalog ids |
|------|------|-------------|
| Int ring axioms | [axioms/DiscreteAxioms.lean](axioms/DiscreteAxioms.lean) | `D-AX-*` |
| Lemma specimens | [lemmas/](lemmas/) | `D-LM-*` |

**TOML source of truth:** `docs/verification/proof-database/entries/discrete-*.toml`.

**Mathlib reference:** `Mathlib.Data.Int.Basic` (commutative ring laws).

```bash
python3 scripts/proof-db/proof-db.py list --field discrete
python3 scripts/proof-db/proof-db.py verify-slice
```