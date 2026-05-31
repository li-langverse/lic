---
workflow_repo: lic
branch: cursor/proof-explorer-phase5-planning
plan: docs/superpowers/plans/proof-explorer-phase5-discharge-sprint.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 5 — Discharge sprint

## North star

Fix compiler audit bugs (BUG-C-01/05/06/07), resolve logic/catalog conflicts (BUG-L-01/05/06), and achieve **≥3 real `lic verify` discharges** in the core corpus. Classify every failure as compiler vs logic before upgrading catalog status.

## Prerequisite

Phase 4 gate must pass (`bash scripts/proof-explorer-phase4-completion-gate.sh`).

## Iteration rules

1. Read `data/proof-explorer-loop/state.json`.
2. Work WP order: **WP-DS-01 → WP-DS-02 → WP-DS-03 → WP-DS-04 → WP-DS-05 → WP-DS-06 → WP-DS-SIGN**.
3. Log each successful discharge to `data/proof-explorer-loop/discharge-log.jsonl`.
4. Commit on `cursor/proof-explorer-phase5-planning` (then `cursor/proof-explorer-phase5`); push every iteration.
5. Append `data/proof-explorer-loop/iteration-log.md`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-DS-01 | BUG-C-01 dot4 loop → Discharge spec or honest downgrade | `bash scripts/proof-explorer-gates/wp-discharge-dot4.sh` |
| WP-DS-02 | BUG-C-05 `witnessed_ensures_ident.li` | manual verify in CI slice |
| WP-DS-03 | BUG-C-06/07 baseline.jsonl sync | `bash scripts/proof-explorer-gates/wp-baseline-sync.sh` |
| WP-DS-04 | BUG-L-01 float policy doc + tagging | `bash scripts/proof-explorer-gates/wp-float-policy.sh` |
| WP-DS-05 | ≥3 core lic verify discharges | `bash scripts/proof-explorer-gates/wp-discharge-core.sh` |
| WP-DS-06 | BUG-L-05/06 catalog conflicts cleared | `bash scripts/proof-explorer-gates/wp4-audit.sh` |
| WP-DS-SIGN | Human discharge review | `data/proof-explorer-loop/wp-discharge.signoff` |

## Do not

- Never edit compiler/ or discharge-pipeline C++ (compiler findings → docs/reports/compiler-audit/ only).
- Set `proof_status = proved` without `lic verify` evidence.
- Fix BUG-C-01 with silent `Prop := True` (must wire Discharge spec or downgrade catalog).
- Batch-discharge all 1217 Erdős rows in this phase.
- Regress Phase 4 Li coverage below 100%.

## Completion gate

```bash
bash scripts/proof-explorer-phase5-completion-gate.sh
```
