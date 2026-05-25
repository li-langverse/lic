# Li proof database (release regression)

**Schema:** [proof-database/schema.toml](proof-database/schema.toml)  
**Related:** [Provability gaps](provability-gaps.md) · [Proof corpus roadmap](proof-corpus-roadmap.md) · [Verification overview](overview.md)

## Purpose

`proof-db/` tracks **axioms → lemmas → Li specimens → Lean artifacts** with a **release pin** per row. A `proved` → `open` regression is usually a **proof tooling gap**, not invalid user Li. **`discrepancy`** means spec and Lean disagree.

## Layout

- `proof-db/manifest.toml` — `[[includes]]` for `axioms/*.toml`, `lemmas/*.toml`

## Entry fields (v1)

| Field | Required | Description |
|-------|----------|-------------|
| `id` | yes | **axiom_id** / lemma id |
| `kind` | yes | `axiom` \| `lemma` |
| `field` | yes | Domain tag |
| `statement` | yes | Human claim |
| `proof_status` | yes | `proved` \| `open` \| `discrepancy` \| `axiomatic` |
| `release_pin` | yes | ISO date verified |
| `li_specimen` | proved lemmas | `.li` path |
| `lean_thm` | optional | Theorem / `vc_*` |
| `gap_id` / `backlog_id` | optional | **G-*** / **P-*** |

## CI (v0)

`scripts/check-proof-db.sh` in `scripts/ci.sh`; `PROOF_DB_SKIP=1` local opt-out.

## v1+

`lic build --proof-db-report`; baseline diff vs prior tag.
