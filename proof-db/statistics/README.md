# proof-db/statistics

Statistics / probability vertical for the Li proof database (**WP2-A**).

| Area | Path | Catalog ids |
|------|------|-------------|
| Probability axioms | [StatsAxioms.lean](StatsAxioms.lean) | `ST-AX-*` |
| Estimation lemmas | [StatsAxioms.lean](StatsAxioms.lean) | `ST-LM-*` (target) |

**TOML source of truth:** `docs/verification/proof-database/entries/statistics-*.toml`.

**Mathlib reference:** `Mathlib.Probability.ProbabilityMassFunction.Basic` (finite mass functions).

```bash
python3 scripts/proof-db/proof-db.py list --field statistics
python3 scripts/proof-db/proof-db.py verify-slice
```
