---
workflow_repo: lic
branch: cursor/proof-explorer-phase12-catalog-quality
plan: docs/superpowers/plans/proof-explorer-phase12-catalog-quality.md
proof_library_branch: main
---

# Proof Explorer Phase 12 — catalog quality

## North star

Reconcile **catalog↔Lean** posture across the full proof database (not only Erdős): honest `proof_status`, cleared physics placeholders, enriched non-Erdős lemma specimens, axiom-layer stub audit, and a fresh **proof-library** `library.json` with reduced divergent count.

## Workspace layout (K8s / local)

- **lic** checkout: `/workspace/lic` — catalog TOML, Lean, specimens (`LIC_ROOT`).
- **proof-library**: sibling `../proof-library` — ingest + PR + Pages.

```bash
export LIC_ROOT=/workspace/lic
python3 scripts/proof-db/compare_reference.py --write
cd /workspace/proof-library
LIC_ROOT=/workspace/lic python3 scripts/build-library.py
bash scripts/check-library-quality.sh
python3 scripts/check-no-proc-in-library.py
```

## Iteration rules

1. Branch **`cursor/proof-explorer-phase12-catalog-quality`** in **lic**.
2. Fix catalog TOML / `proof-db/index.json` where divergence is clear; use `discrepancy` for intentional Lean stub/sorry gaps.
3. Enrich `li_specimen` on math/linalg/discrete rows when specimens exist (no compiler edits).
4. Rebuild proof-library; open PR; merge when CI green.
5. Run `bash scripts/proof-explorer-gates/wp-cq-*.sh` then `bash scripts/proof-explorer-phase12-completion-gate.sh`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-CQ-01 | `compare_reference.py --write`; divergent reconciled or documented | `wp-cq-01-divergence-reconcile.sh` |
| WP-CQ-02 | Physics placeholder rows honest | `wp-cq-02-physics-placeholders.sh` |
| WP-CQ-03 | `std_triangle_ineq_scalar` sorry/downgrade path | `wp-cq-03-sorry-honesty.sh` |
| WP-CQ-04 | Domain + M-AX axiom stub-audit | `wp-cq-04-axiom-specimen-audit.sh` |
| WP-CQ-05 | Non-Erdős lemma enrichment tranche | `wp-cq-05-lemma-enrichment.sh` |
| WP-CQ-06 | proof-library rebuild + quality | `wp-cq-06-proof-library-rebuild.sh` |
| WP-CQ-07 | iteration-log + state.json phase12 | `wp-cq-07-loop-state.sh` |
| WP-CQ-08 | site deploy / merge proof-library | `wp-cq-08-phase12-signoff.sh` |

## Do not

- Mark Erdős **proved** when catalog is **open** / **target**.
- Ship `proc` or `_axiom_witness` / `def main()` in library **li_specimen** snippets.
- Edit `compiler/` from this goal.

## Completion gate

```bash
bash scripts/proof-explorer-phase12-completion-gate.sh
```
