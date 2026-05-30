# proof-db/ml

ML optimization / convergence vertical for the Li proof database (**WP3-A**).

| Area | Path | Catalog ids |
|------|------|-------------|
| Optimization axioms | [OptAxioms.lean](OptAxioms.lean) | `ML-AX-L-SMOOTH` (+ μ-strong-convex layer) |
| Convex domain stub | [Convex.lean](Convex.lean) | `ML-AX-CONVEX-DOM` |
| SGD / GD lemmas | [SGD.lean](SGD.lean) | `ML-LM-GRAD-DESCENT-RATE` |
| Lemma specimens | [lemmas/](lemmas/) | `ML-LM-*` |

**TOML source of truth:** `docs/verification/proof-database/entries/ml-*.toml`.

**Related:** [ml-convergence-program.md](../../docs/verification/ml-convergence-program.md) · **G-ml**

```bash
python3 scripts/proof-db/proof-db.py list --field ml
python3 scripts/proof-db/proof-db.py verify-slice
```
