---
workflow_repo: lic
branch: cursor/proof-explorer-phase3
plan: docs/superpowers/plans/proof-explorer-phase3-research-audit.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 3 — Research audit sprint

## North star

Autonomous research on open problems (Erdős, M-CONJ, or ad-hoc gaps) with **multi-model review** and **Li ground-truth classification**. No model prose counts as proved unless Li discharges it or literature is cited and matched.

Inspired by long-horizon agent research (e.g. elves_skill / Codex on horoconvex-type gaps) — but **Li is the auditor**, not the hype layer.

## Prerequisite

Phase 2 gate must pass (`bash scripts/proof-explorer-phase2-completion-gate.sh`).

## Iteration rules

1. Read `data/proof-explorer-loop/state.json` — use `research_problem_id`.
2. Work WP order: **WP-RA → WP-CL → WP-MR → WP-LV → WP-CM → WP-AU**.
3. Append claims to `proof-db/research-claims/{problem_id}/claims.jsonl` (never only chat).
4. After new claims, run reviewer lane → `reviews.jsonl`.
5. Run Li verification batch before upgrading any `epistemic_status`.
6. Commit on `cursor/proof-explorer-phase3`; push every iteration.
7. Append `data/proof-explorer-loop/iteration-log.md`.

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| WP-RA | Bind one P0 problem; long-horizon loop config | `bash scripts/proof-explorer-gates/wp-ra-problem.sh` |
| WP-CL | Claim ledger schema + JSONL writer | `bash scripts/proof-explorer-gates/wp-claim-ledger.sh` |
| WP-MR | ≥2 reviewer models per claim | `bash scripts/proof-explorer-gates/wp-multi-review.sh` |
| WP-LV | claim-to-li-specimen + lic verify batch | `bash scripts/proof-explorer-gates/wp-li-verify-claims.sh` |
| WP-CM | compare-claims report (model vs Li) | `bash scripts/proof-explorer-gates/wp-claim-compare.sh` |
| WP-AU | proof-library claim audit UI | `data/proof-explorer-loop/wp-au-claim-audit.signoff` |

## Do not

- Set catalog `proof_status = proved` from model review alone.
- Upgrade `epistemic_status` to `li_proved` without `lic verify` or existing Lean discharge.
- Treat reviewer verdict `proved` as sufficient — compare script must flag mismatches.

## Completion gate

```bash
bash scripts/proof-explorer-phase3-completion-gate.sh
```
