---
workflow_repo: lic
branch: cursor/proof-explorer-phase6
plan: docs/superpowers/plans/proof-explorer-phase6-erdos-formalization.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 6 — Erdős P0 + M-CONJ formalization

## North star

≥5 P0 Erdős with `li_proved` or honest partial discharge; ≥3 M-CONJ with non-trivial specimens. E-52 and Bloom Top-10 partial proofs linked to claim ledger.

## Prerequisite

Phase 5 gate must pass (`bash scripts/proof-explorer-phase5-completion-gate.sh`).

## Iteration rules

1. Read `data/proof-explorer-loop/state.json` — prioritize `research_problem_id` (default E-52).
2. Work WP order: **WP-EF-01 → WP-EF-02 → WP-EF-03 → WP-EF-04 → WP-EF-05 → WP-EF-06 → WP-EF-SIGN**.
3. Append discharges to `data/proof-explorer-loop/discharge-log.jsonl`.
4. Sync claim ledger `epistemic_status` when specimens discharge.
5. Commit on `cursor/proof-explorer-phase6`; push every iteration.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-EF-01 | E-52 formalization + sub-specimens | `bash scripts/proof-explorer-gates/wp-erdos-p0-discharge.sh` |
| WP-EF-02 | Bloom Top-10 tranche | same gate (P0 slice) |
| WP-EF-03 | ≥5 P0 discharges or partials | same gate |
| WP-EF-04 | ≥3 M-CONJ non-trivial specimens | `bash scripts/proof-explorer-gates/wp-mconj-formalization.sh` |
| WP-EF-05 | export-math includes li_specimen | `bash scripts/proof-explorer-gates/wp-export-li-specimen.sh` |
| WP-EF-06 | E-52 claim ↔ catalog sync | manual compare report |
| WP-EF-SIGN | Human P0/M-CONJ review | `data/proof-explorer-loop/wp-erdos-formalization.signoff` |

## Do not

- Upgrade E-52 main conjecture to `proved` from model consensus.
- Skip M-CONJ track (gate requires both Erdős and M-CONJ).
- Regress Phase 5 core discharges.
- Formalize with `# TODO` only bodies on M-CONJ gate rows.

## Completion gate

```bash
bash scripts/proof-explorer-phase6-completion-gate.sh
```
