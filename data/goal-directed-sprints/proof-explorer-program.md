---
workflow_repo: lic
branch: cursor/proof-explorer-program
plan: docs/superpowers/plans/proof-explorer-program.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 2 — goal-directed sprint

## North star

Ship learner-facing explorer: proof-library UI, editorial overlays, Tier-B context for P0/P1 Erdos problems.

Phase 1 (schema v3, 1217 Erdos ingest, export-math, gates) is merged — do not regress wp0–wp4 gates.

## Iteration rules

1. Read `data/proof-explorer-loop/state.json`.
2. Work in order: **WP5 → WP6 → Tier-B polish**.
3. Commit on `cursor/proof-explorer-phase2`; push every iteration.
4. Run the relevant gate before marking a WP done.
5. Append one row to `data/proof-explorer-loop/iteration-log.md`.

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| WP5 | proof-library explorer UI (separate repo PR) | Create `data/proof-explorer-loop/wp5-proof-library.signoff` with PR URL after opening PR |
| WP6 | `proof-db/erdos/overlays.json` editorial tranches | >=5 overlay rows; never overwrite `content_tier=polished` |
| Tier-B | P0/P1 Erdos context + sources | >=20 register rows with context/sources and content_tier curated/polished |

## Do not

- Mark `proof_status = proved` without Lean discharge + literature match.
- Overwrite hand-polished rows with auto ingest.
- Re-run full Phase 1 ingest unless wp1-ingest gate fails.

## Completion gate

```bash
bash scripts/proof-explorer-phase2-completion-gate.sh
```