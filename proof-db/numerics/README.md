# proof-db/numerics

Floating-point numerics vertical for the Li proof database (**WP1**).

| Area | Path | Catalog ids |
|------|------|-------------|
| FP / libm axioms | [axioms/NumericsAxioms.lean](axioms/NumericsAxioms.lean) | `N-AX-*` |
| Lemma specimens | [lemmas/](lemmas/) | `N-LM-*` |

**TOML source of truth:** `docs/verification/proof-database/entries/numerics-*.toml`.

**Discharge bridge:** `Li.Discharge.sqrt_open_bound_spec` + `li-tests/contracts_verify/sqrt_open_bound.li`.

```bash
python3 scripts/proof-db/proof-db.py list --field numerics
python3 scripts/proof-db/proof-db.py verify-slice
```