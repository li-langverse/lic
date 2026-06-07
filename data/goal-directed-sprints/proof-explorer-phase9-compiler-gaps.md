---
workflow_repo: lic
branch: cursor/proof-explorer-compiler-gaps
plan: docs/superpowers/plans/proof-explorer-phase9-compiler-gaps.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 9 — compiler gap closure

## North star

Close the **honesty loop** between compiler gap scripts, proof-db discrepancies, and catalog `proof_status`. Dot4 loop discharge landed in PR #696; remaining BUG-C rows stay open until Julian ships compiler fixes — agents document, reconcile, and prevent false `proved` claims.

## Iteration rules

1. Read `data/proof-explorer-loop/state.json` (phase 9 / `wp-cg-01` … `wp-cg-06`).
2. Work WPs in order: audit index → regression → discrepancies → catalog honesty → optional destub.
3. Branch `cursor/proof-explorer-compiler-gaps` (or `main` after merge); push each iteration.
4. Run `bash scripts/proof-explorer-gates/wp-compiler-gap-<name>.sh` for the active WP.
5. Refresh discrepancies: `python3 scripts/proof-db/compare_reference.py --write`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-CG-01 | Confirm dot4 merge on `main` | `dot4_loop_ensures_lean_stub_gap.sh` exits 0 (when `lic` built) |
| WP-CG-02 | `docs/reports/compiler-audit/` README + BUG-C-01..12 | `wp-compiler-gap-audit-index.sh` |
| WP-CG-03 | CI-friendly regression wrapper for all `*_gap.sh` | `wp-compiler-gap-regression.sh` |
| WP-CG-04 | Updated `proof-database/discrepancies.json` + DISCREPANCIES.md | `wp-discrepancy-reconcile.sh` |
| WP-CG-05 | No `proved` rows contradicting open gaps | `wp-catalog-honesty.sh` |
| WP-CG-06 | (Optional) CallProc specimen destub notes | `wp-destub-proc-specimens.sh` |

## Do not

- Edit `compiler/`, `vc_emit_lean.cpp`, `vc_witness.cpp`, or `Discharge.lean` from this goal.
- Mark `proof_status = proved` while the matching `*_gap.sh` fails.
- Silence gap scripts by weakening assertions — update catalog/docs instead.

## Completion gate

```bash
bash scripts/proof-explorer-phase9-completion-gate.sh
```
