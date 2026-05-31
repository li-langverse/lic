---
workflow_repo: lic
branch: cursor/proof-explorer-basic-corpus
plan: docs/superpowers/plans/proof-explorer-phase8-basic-corpus.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 8 — basic foundational corpus

## North star

Ingest ~250 axiom/lemma/target catalog rows with matching `.li` specimens across physics, physical chemistry, statistics, discrete mathematics, and graph theory. Stress-test Li language coverage without requiring full Lean discharge.

## Iteration rules

1. Read `data/proof-explorer-loop/state.json` (phase 8 / `wp-bc-01`).
2. Work tranches in order: **tranche 1 (50)** → **tranche 2** → **tranche 3** per field plan.
3. Branch `cursor/proof-explorer-basic-corpus`; push each iteration.
4. Regenerate from manifests: `python3 scripts/formalization/bootstrap-basic-corpus.py all --tranche N --limit 50`.
5. Run `python3 scripts/proof-db/proof-db.py verify-slice` after each bootstrap.
6. For tranche gates, use lowered mins, e.g. `MIN_PHYSICS=10 MIN_BASIC_CORPUS_TOTAL=50 bash scripts/proof-explorer-phase8-completion-gate.sh`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-BC-01 | Planning manifests under `docs/verification/basic-corpus/` | Files exist (5 fields × ~50 planned) |
| WP-BC-02 | `bootstrap-basic-corpus.py` + tranche 1 catalog + specimens | `verify-slice` OK; ≥50 `phase8-basic-corpus` rows |
| WP-BC-03 | Tranche 2 bootstrap (~100 cumulative) | Per-field ≥20 with `MIN_*=20` |
| WP-BC-04 | Full bootstrap (~250) | `proof-explorer-phase8-completion-gate.sh` (200+ rows) |
| WP-BC-05 | Li specimen spot-check / compile smoke (no `compiler/` edits) | Report in `docs/reports/` if gaps |

## Do not

- Edit `compiler/` (file gaps → `docs/reports/compiler-audit/` only).
- Mark `proof_status = proved` without discharge.
- Overwrite curated Erdos or existing physics axiom rows.

## Completion gate

```bash
bash scripts/proof-explorer-phase8-completion-gate.sh
```
