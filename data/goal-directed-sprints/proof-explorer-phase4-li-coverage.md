# Proof Explorer Phase 4 — Li coverage invariant

**North star:** Every catalog row has a **Li specimen on disk** (open stub or discharged proof) or is **axiomatic with Lean module**. No metadata-only rows.

**Invariant doc:** `docs/verification/proof-database/li-coverage-invariant.md`

## Work packages

| WP | Deliverable |
|----|-------------|
| WP-LC-A | `check-li-coverage.py` + `bootstrap-specimen-stubs.py` + gate |
| WP-LC-B | Erdős literature-proved rows: catalog `proof_status=target` until Li discharge |
| WP-LC-C | Strengthen stubs → partial formalizations (P0 Erdős, M-CONJ) |
| WP-LC-D | `lic verify` discharge for specimens; upgrade to `proof_status=proved` only with evidence |
| WP-LC-E | export-math includes `li_specimen` for all fields |

## Do not

- Set `proof_status=proved` without `# discharge: ok` / `lean_thm` / verify log
- Leave catalog rows without `li_specimen` file on disk

## Completion gate

```bash
bash scripts/proof-explorer-phase4-completion-gate.sh
```

Requires 100% Li coverage (all tranches) and `data/proof-explorer-loop/wp-li-coverage.signoff`.

When exit 0 → `GOAL_COMPLETE`.
