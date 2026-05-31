---
workflow_repo: lic
branch: cursor/proof-explorer-program
plan: docs/superpowers/plans/proof-explorer-program.md
attribution: proof-db/attribution.toml
---

# Proof Explorer — goal-directed sprint

## North star

Learners can explore ~1,200 Erdős problems with plain-text math, LaTeX, context, and sources.
Footer on every page: **Li Proof Library** + **Curated by Julian Kleber** ([julianmkleber.com](https://julianmkleber.com) / [@capjmk](https://x.com/capjmk)).

## Iteration rules

1. Read `data/proof-explorer-loop/state.json` and the Proof Explorer WP plan.
2. Pick the next incomplete WP in order: **WP-K8 → WP0 → WP1 → WP4 → WP5 → WP2 → WP3**.
3. Implement the smallest shippable slice; commit on `cursor/proof-explorer-program`; push.
4. Run the phase completion gate before marking a WP done.
5. Append one row to `data/proof-explorer-loop/iteration-log.md`.

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| WP-K8 | K8s worker + this sprint running on engine | `bash scripts/proof-explorer-gates/wp-k8-deploy.sh` |
| WP0 | schema v3 + attribution.toml + style guide | `bash scripts/proof-explorer-gates/wp0-schema.sh` |
| WP1 | ingest ~1200 Erdős rows (Tier A min) | `bash scripts/proof-explorer-gates/wp1-ingest.sh` |
| WP4 | content audits in CI | `bash scripts/proof-explorer-gates/wp4-audit.sh` |
| WP5 | proof-library explorer UI (separate repo PR) | manual sign-off in iteration log |
| WP2 | M-CONJ rich fields | `grep M-CONJ-ABC docs/verification/proof-database/entries/math-conjectures.toml` |
| WP3 | `lic export-math` MVP | `bash scripts/proof-explorer-gates/wp3-export-math.sh` |

## Completion gate (program)

```bash
bash scripts/proof-explorer-completion-gate.sh
```

Exit 0 only when WP0 + WP1 Tier-A + WP4 advisory gates pass.

## Do not

- Mark `proof_status = proved` without Lean discharge + literature match.
- Overwrite hand-polished `content_tier=polished` rows with auto ingest.

- Mark `proof_status = proved` without Lean discharge + literature match.
- Overwrite hand-polished `content_tier=polished` rows with auto ingest.
