# proof-db/graph

Graph theory vertical for the Li proof database (**WP4-A**).

| Area | Path | Catalog ids |
|------|------|-------------|
| Simple graph axioms & lemma stubs | [GraphAxioms.lean](GraphAxioms.lean) | `GT-AX-SIMPLE-GRAPH`, `GT-LM-HANDSHAKING`, `GT-LM-TREE-EDGES` |

**TOML source of truth:** `docs/verification/proof-database/entries/graph-*.toml`.

**Mathlib reference:** `Mathlib.Combinatorics.SimpleGraph.*` (degree sum, trees).

**Gap:** **G-graph** — see [provability-gaps.md](../../docs/verification/provability-gaps.md).

```bash
python3 scripts/proof-db/proof-db.py list --field graph
python3 scripts/proof-db/proof-db.py verify-slice
```
