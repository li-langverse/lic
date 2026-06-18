---
workflow_repo: lic
branch: cursor/proof-explorer-phase7
plan: docs/superpowers/plans/proof-explorer-phase7-research-at-scale.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 7 — Research audit at scale

## North star

≥3 research problems with claim ledger + compare reports; proof-library consumes full export-math with `li_specimen` links. Scales Phase 3 pattern beyond E-52.

## Prerequisite

Phase 6 gate must pass (`bash scripts/proof-explorer-phase6-completion-gate.sh`).

## Iteration rules

1. Rotate `research_problem_id` in `state.json` across ≥3 problems.
2. Work WP order: **WP-RS-01 → WP-RS-02 → WP-RS-03 → WP-RS-04 → WP-RS-05 → WP-RS-06 → WP-RS-SIGN**.
3. Append claims + reviews per problem; never chat-only results.
4. Run compare before catalog upgrades.
5. Commit on `cursor/proof-explorer-phase7`; push every iteration.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-RS-01 | ≥3 problem ledgers (≥10 claims each) | `bash scripts/proof-explorer-gates/wp-research-scale.sh` |
| WP-RS-02 | Li verify batch per problem | `bash scripts/proof-explorer-gates/wp-li-verify-claims.sh` |
| WP-RS-03 | compare-claims per problem | `bash scripts/proof-explorer-gates/wp-claim-compare.sh` |
| WP-RS-04 | Full-field export with li_specimen | `wp-export-li-specimen.sh` + `wp3-export-math.sh` |
| WP-RS-05 | proof-library export integration | `bash scripts/proof-explorer-gates/wp-proof-library-export.sh` |
| WP-RS-06 | Long-horizon K8s loop profile | `bash scripts/proof-explorer-gates/wp-ra-problem.sh` |
| WP-RS-SIGN | Program completion review | `data/proof-explorer-loop/wp-research-scale.signoff` |

## Do not

- Hide model_conflict or unprovable_language_flags in UI.
- Ship proof-library without li_specimen in export.
- Treat this phase as "discharge entire corpus."
- Disable Phase 3 sub-gates.

## Completion gate

```bash
bash scripts/proof-explorer-phase7-completion-gate.sh
```
