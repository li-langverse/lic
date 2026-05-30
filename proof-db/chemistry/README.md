# proof-db/chemistry

Computational chemistry / quantum-chemistry vertical for the Li proof database (**WP7**).

| Area | Path | Catalog ids |
|------|------|-------------|
| HF / SCF axioms & lemma stubs | [ChemAxioms.lean](ChemAxioms.lean) | `CHEM-AX-*`, `CHEM-LM-SCF-ENERGY-DECREASE` |
| SCF energy specimen | [lemmas/scf_energy_decrease_stub.li](lemmas/scf_energy_decrease_stub.li) | `CHEM-LM-SCF-ENERGY-DECREASE` |

**TOML source of truth:** `docs/verification/proof-database/entries/chemistry-*.toml`.

**Benchmark refs:** `benchmarks/tier2_physics/qm_*` (SCF / DFT smokes).

**Gap:** **G-chem** — see [provability-gaps.md](../../docs/verification/provability-gaps.md).

```bash
python3 scripts/proof-db/proof-db.py list --field chemistry
python3 scripts/proof-db/proof-db.py verify-slice
```