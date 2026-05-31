---
workflow_repo: lic
branch: cursor/proof-explorer-proof-sweep
plan: docs/superpowers/plans/proof-explorer-phase7-research-at-scale.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 7 — sweep handoff to complete

## North star

Sweep log complete for the full catalog; **≥3** research problems touched (claim ledgers and/or Erdős ids in sweep log). proof-library export links remain; verify/compare failures are non-blocking.

## Prerequisite

Phase 6 sweep gate passes (`bash scripts/proof-explorer-phase6-completion-gate.sh`).

## Iteration rules

1. Ensure `proof-sweep-log.jsonl` covers all catalog ids (`wp-proof-sweep.sh`).
2. Rotate `research_problem_id` in `state.json` when extending claim ledgers (optional).
3. Append `iteration-log.md`; commit on `cursor/proof-explorer-proof-sweep`.
4. Set `LI_PROOF_EXPLORER_SWEEP_MODE=1` on the worker for non-fatal verify gates.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-SW-05 | ≥3 problems in sweep / claims | `bash scripts/proof-explorer-gates/wp-proof-sweep-research.sh` |
| WP-SW-06 | export + math bundle | `wp-export-li-specimen.sh` + `wp3-export-math.sh` |
| WP-SW-07 | proof-library export signoff | `wp-proof-library-export.sh` (optional in sweep mode) |
| WP-SW-SIGN | Program sweep complete | `data/proof-explorer-loop/wp-proof-sweep-complete.signoff` |

## Do not

- Treat this phase as "discharge entire corpus."
- Hide `model_conflict` in compare reports when present.
- Block on `wp-li-verify-claims` / `wp-claim-compare` when sweep mode is on.

## Completion gate

```bash
bash scripts/proof-explorer-phase7-completion-gate.sh
```
