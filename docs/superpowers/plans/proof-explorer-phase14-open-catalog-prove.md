# Proof Explorer Phase 14 — open catalog prove

**Branch (lic):** `cursor/proof-explorer-phase14-open-catalog-prove`  
**Goal sprint:** `data/goal-directed-sprints/proof-explorer-phase14-open-catalog-prove.md`  
**Completion gate:** `scripts/proof-explorer-phase14-completion-gate.sh`

## Target state

| Dimension | Target |
|-----------|--------|
| Catalog | `proof_status = "open"` count **0** across all TOML entries |
| Lean scan | `lean_status` agrees with catalog (**0 divergent**) |
| Site | `library.json` `lic_commit` == `lic` `origin/main` |
| Honesty | No proved row while mapped gap script fails |
| Worker | K8s `li-proof-explorer` on phase 14 until gate passes |

## Baseline (2026-06-07)

| Bucket | Open | Notes |
|--------|-----:|-------|
| Erdős register | ~901 | Prove only with real Lean; no fake labels |
| Non-Erdős | ~208 | P-linalg, physics, math, graph, ML backlog |
| Target | 7 | Promote to proved or keep honestly open |
| **Total open** | **~1,109** | Completion gate requires **0** |

## Work packages

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-PR-01 | Inventory + `phase14-baseline.json` | `wp-pr-01-open-inventory.sh` |
| WP-PR-02 | Per-iteration discharge progress | `wp-pr-02-discharge-tranche.sh` |
| WP-PR-03 | Catalog honesty | `wp-pr-03-catalog-honesty.sh` |
| WP-PR-04 | proof-library sync | `wp-pr-04-proof-library-sync.sh` |
| WP-PR-05 | Non-Erdős open = 0 | `wp-pr-05-non-erdos-closed.sh` |
| WP-PR-06 | All open = 0 | `wp-pr-06-all-open-closed.sh` |
| WP-PR-07 | Signoff + iteration log | `wp-pr-07-phase14-signoff.sh` |

## Discharge priority (suggested order)

1. Rows with existing Li specimens + failing gap scripts (P-linalg, P-float, P-par).
2. `proof-db/lemmas/*.toml` with `lean_thm` already in `Discharge.lean`.
3. Physics / math lemma TOML with partial discharge hooks.
4. Graph, numerics, discrete axiom-derived lemmas.
5. Erdős register — only when a formal proof lands in Lean.

## Verification

```bash
bash scripts/proof-explorer-phase14-completion-gate.sh
```

## K8s

ConfigMap `li-proof-explorer`: goal file phase14, branch `cursor/proof-explorer-phase14-open-catalog-prove`, `LI_GOAL_SCALE_DOWN_ON_COMPLETE=0`, `LI_PROOF_EXPLORER_ALWAYS_ON=1`.
