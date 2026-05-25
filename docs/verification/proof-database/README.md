# Proof database

**Schema:** [schema.toml](schema.toml) · **CLI:** `scripts/proof-db/proof-db.py`

## Purpose

Versioned **axiom → lemma → discharge status** vs `last_verified_lic_commit`. Complements [provability gaps](../provability-gaps.md) (`G-*`) and [proof corpus roadmap](../proof-corpus-roadmap.md) (`P-*`). `discrepancy` = triage gap, not “Li is wrong”.

## Entry fields

| Field | Required |
|-------|----------|
| `id`, `kind`, `field`, `statement`, `proof_status` | yes |
| `lean_module`, `last_verified_lic_commit` | yes |
| `li_specimen`, `lean_thm`, `gap_id`, `backlog_id`, `evidence`, `notes` | optional |

`proof_status`: `proved` | `open` | `discrepancy` | `axiomatic`.  
`kind`: `axiom` | `lemma`.  
`field`: `math` | `physics` | `compiler` | `linalg` | `trust`.

## Layout

- `entries/*.toml` — bulk `[[entry]]` tables  
- `proof-db/lemmas/*.toml` — optional single-row pins (`corpus_root`)

## Agents

```bash
python3 scripts/proof-db/proof-db.py list
python3 scripts/proof-db/proof-db.py verify-slice
python3 scripts/proof-db/proof-db.py add-entry --kind lemma --id P-new \
  --field linalg --status open --statement "..." \
  --lean-module build/generated/AutoVC.lean \
  --li-specimen li-tests/contracts_verify/foo.li --gap-id G-math
```

Update **G-proof-db** in provability-gaps in the same PR.

## Learned from

- **Lean mathlib** — stable ids + theorem naming  
- **Coq stdlib** — axiom/lemma layering  
- **Dafny corpus** — specimen + evidence scripts per row  
