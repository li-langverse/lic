# E-52 claim ledger ↔ catalog sync (WP-EF-06)

Generated: 2026-05-31 · branch `cursor/proof-explorer-phase6`

## Catalog row

| Field | Value |
|-------|-------|
| id | E-52 |
| proof_status | open (main conjecture) |
| priority_tier | P0 |
| li_specimen | proof-db/erdos/specimens/E-52.li |
| partial specimen | proof-db/erdos/specimens/E-52-partial-sumset-card.li |

## Claim ledger crosswalk

| claim_id | epistemic_status | specimen | sync |
|----------|------------------|----------|------|
| CLM-E52-001 | heuristic | — | no Li discharge (AP obstruction only) |
| CLM-E52-002 | literature_proved | — | literature anchor; not re-proved |
| CLM-E52-003 | heuristic | — | R vs Z distinction; no discharge |
| CLM-E52-004 | li_proved | specimens/cardinality_sumset_lower.li | **synced** — partial discharge in Phase 6 |
| CLM-E52-005 | model_consensus | — | not upgraded (honesty rule) |
| CLM-E52-006 | model_conflict | — | not upgraded |
| CLM-E52-007 | heuristic | — | no discharge |
| CLM-E52-008 | heuristic | — | no discharge |
| CLM-E52-009 | literature_proved | — | literature anchor |
| CLM-E52-010 | refuted | — | audit lane |
| CLM-E52-011 | heuristic | — | no discharge |
| CLM-E52-012 | heuristic | — | methodological |

## Honesty check

- Main E-52 conjecture remains `proof_status = open` in catalog.
- CLM-E52-004 upgraded to `li_proved` after partial specimen discharge.
- No model-consensus claim promoted to `proved` on the main conjecture.

## Result

≥1 claim row (`CLM-E52-004`) with honest `li_proved` partial refinement linked to catalog specimen.
