---
workflow_repo: lic
branch: cursor/proof-explorer-proof-sweep
plan: docs/superpowers/plans/proof-explorer-phase6-erdos-formalization.md
attribution: proof-db/attribution.toml
---

# Proof Explorer Phase 6 — proof corpus sweep

## North star

One human/agent pass through the entire proof corpus: all **1290** catalog entries plus `proof-db/**/*.li` specimens logged in `proof-sweep-log.jsonl`. Failing `lic verify` or missing discharges are **logged, not blocking**.

## Prerequisite

Phase 5 gate passes, or `LI_PROOF_EXPLORER_SWEEP_MODE=1` with sweep infrastructure on branch `cursor/proof-explorer-proof-sweep`.

## Iteration rules

1. Run `python3 scripts/formalization/proof-catalog-sweep.py` (append) or `--full` for a fresh pass.
2. Document each catalog id in `data/proof-explorer-loop/proof-sweep-log.jsonl` with honest `sweep_status` (`reviewed|skipped|stub|discharged`).
3. Append one row to `data/proof-explorer-loop/iteration-log.md` per iteration.
4. Commit on `cursor/proof-explorer-proof-sweep`; push every iteration.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-SW-01 | Seed / extend sweep log | `python3 scripts/formalization/proof-catalog-sweep.py --full` |
| WP-SW-02 | ≥1290 catalog ids in log | `bash scripts/proof-explorer-gates/wp-proof-sweep.sh` |
| WP-SW-03 | P0 Erdős touched in log | `bash scripts/proof-explorer-gates/wp-proof-sweep-p0.sh` (or legacy discharge) |
| WP-SW-04 | export-math li_specimen | `bash scripts/proof-explorer-gates/wp-export-li-specimen.sh` |
| WP-SW-SIGN | Sweep complete (not all proofs pass) | `data/proof-explorer-loop/wp-proof-sweep.signoff` |

## Do not

- Block phase handoff on per-specimen `lic verify` failures.
- Require ≥5 P0 `li_proved` discharges (legacy; optional via `wp-erdos-p0-discharge.sh`).
- Skip logging stubs or open conjectures — mark `stub` / `reviewed` with a note.

## Completion gate

```bash
bash scripts/proof-explorer-phase6-completion-gate.sh
```
