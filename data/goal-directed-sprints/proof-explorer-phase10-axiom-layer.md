---
workflow_repo: lic
branch: cursor/proof-explorer-phase10-axiom-layer
plan: docs/superpowers/plans/proof-explorer-phase10-axiom-layer.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 10 — axiom layer

## North star

Replace placeholder axiom witnesses with **statement-aligned Li contracts**, wire catalog metadata (`li_axiom_symbol`, `specimen_role`), improve proof-library axiom presentation, and file **BUG-C-13** compiler RFC for Julian — without editing `compiler/` from this goal.

## Iteration rules

1. Read `data/proof-explorer-loop/state.json` (phase 10 / `wp-ax-01` … `wp-ax-12`).
2. Work WPs in order when possible: Peano → reals → corpus → catalog → library → RFC check → stub audit → library rebuild → loop state.
3. Branch `cursor/proof-explorer-phase10-axiom-layer`; push each iteration.
4. Run `bash scripts/proof-explorer-gates/wp-ax-<NN>-*.sh` for the active WP.
5. After catalog edits: `python3 scripts/proof-db/proof-db.py verify-slice`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-AX-01 | Peano/order one-file-per-axiom | `wp-ax-01-math-peano-contracts.sh` |
| WP-AX-02 | `reals_field.li` field laws | `wp-ax-02-math-reals-field.sh` |
| WP-AX-03 | basic-corpus axiom formulations | `wp-ax-03-basic-corpus-axioms.sh` |
| WP-AX-04 | Erdős open enrichment | `wp-ax-04-erdos-open-enrich.sh` |
| WP-AX-05 | Catalog axiom fields + schema | `wp-ax-05-catalog-axiom-fields.sh` |
| WP-AX-06 | proof-library AXIOM UI | `wp-ax-06-proof-library-axiom-ui.sh` |
| WP-AX-07 | BUG-C-13 RFC (Julian) | `wp-ax-07-compiler-rfc-present.sh` |
| WP-AX-08 | stub-audit (catalog paths) | `wp-ax-08-stub-audit-catalog.sh` |
| WP-AX-09 | `library.json` rebuild | `wp-ax-09-rebuild-library-json.sh` |
| WP-AX-10 | iteration-log + state.json | `wp-ax-10-loop-state.sh` |

## Do not

- Edit `compiler/`, `vc_emit_lean.cpp`, `vc_witness.cpp`, or `Discharge.lean` from this goal.
- Add axioms to `docs/semantics/trusted.lean`.
- Mark `proof_status = proved` for specimens still failing phase-9 gap scripts.
- Use `ensures result == 0` as the *only* contract on an axiom specimen (witness-only).

## Completion gate

```bash
bash scripts/proof-explorer-phase10-completion-gate.sh
```
