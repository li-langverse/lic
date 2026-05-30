# proof-db/biology

Computational biology vertical for the Li proof database (**WP8**).

| Area | Path | Catalog ids |
|------|------|-------------|
| Folding / alignment axioms & lemma stubs | [BioAxioms.lean](BioAxioms.lean) | `BIO-AX-*`, `BIO-LM-*` |

**TOML source of truth:** `docs/verification/proof-database/entries/biology-*.toml`.

**Benchmark refs:** `benchmarks/tier2_physics/bio_*` (Rosetta / rotamer smokes).

**Gap:** **G-bio** — see [provability-gaps.md](../../docs/verification/provability-gaps.md).

```bash
python3 scripts/proof-db/proof-db.py list --field biology
python3 scripts/proof-db/proof-db.py verify-slice
```