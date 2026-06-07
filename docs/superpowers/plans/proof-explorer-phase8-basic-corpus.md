# Proof Explorer Phase 8 — basic corpus

**Branch:** `cursor/proof-explorer-basic-corpus`  
**Goal sprint:** `data/goal-directed-sprints/proof-explorer-phase8-basic-corpus.md`  
**Schema:** v3 (`docs/verification/proof-database/schema.toml`)

## Audit baseline (pre-phase8)

| Field | Catalog rows | With `li_specimen` | `proof-db/{field}` `.li` |
|-------|-------------|-------------------|---------------------------|
| physics | 10 | 6 | 6 |
| chemistry | 4 | 1 | 1 |
| statistics | 3 | 0 | 0 |
| discrete | 6 | 6 | 2 |
| graph | 3 | 0 | 0 |
| math | 30 | 15 | 8 |
| erdos | 1217 | 0 | — |

**Target:** +250 planned (`P-AX-BC-*`, `ST-*-BC-*`, `D-*-BC-*`, `GT-*-BC-*`, `CHEM-*-BC-*`), ≥200 ingested with specimens for phase completion.

## Work packages

| WP | Scope | Tranche | Done when |
|----|-------|---------|-----------|
| WP-BC-01 | Manifests `docs/verification/basic-corpus/*-basic.toml` | — | 5 manifests, ~50 ids each |
| WP-BC-02 | Bootstrap pipeline + catalog slices | 1 | ≥50 new rows + `.li` stubs |
| WP-BC-03 | Physics + chem tranche 2 | 2 | ≥20/field |
| WP-BC-04 | Stats + discrete tranche 2 | 2 | ≥20/field |
| WP-BC-05 | Graph tranche 2–3 | 2–3 | ≥20/field |
| WP-BC-06 | Full tranche 3 + gates | 3 | phase8 completion gate |

## Tranche table (~50 per field)

### Physics (50) — `physics-basic.toml`

| Tranche | IDs | Topics |
|---------|-----|--------|
| 1 | `P-*-BC-MEC-001` … `010` | Newton, momentum, energy |
| 2 | `P-*-BC-EM-011` … `030` | EM + thermo axioms/lemmas |
| 3 | `P-*-BC-WV-031` … `050` | Waves/fluids + extras |

### Statistics (50) — `stats-basic.toml`

| Tranche | IDs | Topics |
|---------|-----|--------|
| 1 | `ST-*-BC-*-001` … `010` | Probability axioms, expectation, variance |
| 2 | `011` … `020` | Inequalities, Bayes, covariance |
| 3 | `021` … `050` | CLT targets, distributions |

### Discrete (50) — `discrete-basic.toml`

| Tranche | Topics |
|---------|--------|
| 1 | Induction, combinatorics |
| 2 | Number theory, recurrence |
| 3 | Logic/set schema axioms |

### Graph (50) — `graph-basic.toml`

| Tranche | Topics |
|---------|--------|
| 1 | Handshaking, trees |
| 2 | Connectivity, coloring bounds |
| 3 | Matching/flow stubs |

### Physical chemistry (50) — `chem-basic.toml`

| Tranche | Topics |
|---------|--------|
| 1 | Ideal gas, rate laws |
| 2 | Equilibrium, Gibbs |
| 3 | Thermodynamic identities / conservation |

## Tooling

```bash
python3 scripts/formalization/bootstrap-basic-corpus.py write-manifests
python3 scripts/formalization/bootstrap-basic-corpus.py bootstrap --tranche 1 --limit 50
python3 scripts/formalization/bootstrap-basic-corpus.py patch-manifest
python3 scripts/proof-db/proof-db.py verify-slice
```

## Gates

- Per-field: `scripts/proof-explorer-gates/wp-basic-corpus-{physics,stats,discrete,graph,chem}.sh`
- Phase: `scripts/proof-explorer-phase8-completion-gate.sh` (default ≥200 total, ≥40/field)

## K8s (optional)

Point `li-cursor-agents` ConfigMap `LIC_BRANCH=cursor/proof-explorer-basic-corpus`, scale proof-explorer worker to 1, goal file `proof-explorer-phase8-basic-corpus.md`.
