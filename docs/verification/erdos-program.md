# Erdős program — agent workflow (WP0-B)

**Audience:** agents extending the proof database with curated Erdős problems without claiming false discharge.

**Register:** `proof-db/erdos/register.json`  
**Roadmap / tiers:** `proof-db/erdos/ROADMAP.md`  
**Catalog:** `docs/verification/proof-database/entries/erdos-register.toml` (`E-{number}`)  
**Index:** [proof-database.md](proof-database.md) · [proof-database/entries/README.md](proof-database/entries/README.md)

## When to use this doc

- Adding or re-tiering Erdős rows in the register.
- Syncing register → catalog TOML.
- Planning formalization (`erdos_status = target`) before Lean/specimens exist.

## Workflow

1. **Read** `proof-db/erdos/ROADMAP.md` (P0–P3 policy) and the row schema `register.schema.json`.
2. **Edit** `proof-db/erdos/register.json` — use real Erdős numbers and statements; set `priority_tier` and `erdos_status`.
3. **Sync** from `lic` root:

   ```bash
   python3 proof-db/erdos/scripts/erdos_sync_catalog.py --limit 20
   python3 proof-db/erdos/scripts/erdos_sync_catalog.py
   ```

4. **Review** `erdos-register.toml`: each row must have `id = E-{number}`, `kind = target`, `field = erdos`.
5. **Do not** set `proof_status = proved` unless literature + Lean discharge match; use `erdos_status = proved` in the register and re-sync.
6. **Promote to formal work:** change `erdos_status` to `target`, add `li_specimen` in a follow-up PR (WP1+), wire **G-erdos** in [provability-gaps.md](provability-gaps.md).
7. **Verify** (optional): `python3 scripts/proof-db/rebuild_lemmas.py` picks up new `entries/*.toml` rows.

## `erdos_status` semantics

| Status | Agent action |
|--------|----------------|
| `open` | Catalog metadata only; no specimen. |
| `proved` | Record outcome; `proof_status` syncs to `proved`; cite note in register `notes` if helpful. |
| `target` | Active slice: add specimen + gap doc before claiming progress in release notes. |

## Tier selection (quick)

- **P0:** Goldbach (#86), twin primes (#87), prime gaps (#25, #69, #89), Collatz (#47), RH-linked (#128), weak Goldbach landed (#115).
- **P1:** Geometry (#16, #18), covering systems (#39, #68), abc (#61), Turán-type (#110, #140).
- **P2/P3:** Completeness and specialized rows — sync but defer formalization.

## PR checklist

- [ ] `register.json` validates against `register.schema.json`
- [ ] `erdos_sync_catalog.py` run; TOML committed if catalog-visible
- [ ] No bogus `proof_status = proved` on open conjectures
- [ ] ROADMAP / this doc updated if tier policy changes
