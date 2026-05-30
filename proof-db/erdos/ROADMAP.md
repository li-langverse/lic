# Erdős register — program roadmap (WP0-B)

**Register:** `proof-db/erdos/register.json`  
**Schema:** `register.schema.json`  
**Catalog sync:** `proof-db/erdos/scripts/erdos_sync_catalog.py` → `docs/verification/proof-database/entries/erdos-register.toml`  
**Agent workflow:** [erdos-program.md](../../docs/verification/erdos-program.md)

## Priority tiers (P0–P3)

| Tier | Intent | Agent use |
|------|--------|-----------|
| **P0** | Flagship open problems tied to Li number-theory / proof-corpus goals (Goldbach, twin primes, prime gaps, Collatz-class). First formal targets and bench oracles. | Pick before P1; update `erdos_status` to `target` when a slice is in active work. |
| **P1** | High-profile classics (distinct distances, covering systems, abc-class). Specimens and gap docs after P0 slices land. | Schedule after P0 `target` rows close or stall. |
| **P2** | Standard catalog rows for completeness; partial results OK. | Bulk sync; no Lean work unless unblocked. |
| **P3** | Niche or heavily specialized; documentation and cross-links only. | Do not spend formalization budget unless promoted. |

Tiers are **curator policy**, not mathematical difficulty. Re-tier in the same PR that changes `register.json`.

## `erdos_status` vs proof-database `proof_status`

| `erdos_status` | Meaning | Synced `proof_status` |
|----------------|---------|------------------------|
| `open` | Unsolved in the literature (register tracks conjecture). | `open` |
| `proved` | Accepted solution exists (register records outcome). | `proved` |
| `target` | Li program owns a formalization slice (specimen / Lean plan). | `open` (until discharge closes) |

Catalog rows use `kind = "target"` and `field = "erdos"` — an extension to the proof-database v1 schema documented here, not a discharged lemma.

## Sync to catalog

1. Edit `register.json` (validate against `register.schema.json`).
2. Run from `lic` root:

   ```bash
   python3 proof-db/erdos/scripts/erdos_sync_catalog.py
   python3 proof-db/erdos/scripts/erdos_sync_catalog.py --limit 20   # first N by number
   python3 proof-db/erdos/scripts/erdos_sync_catalog.py --dry-run
   ```

3. Commit **both** `register.json` and `erdos-register.toml` when catalog-visible rows change.
4. Optional: `python3 scripts/proof-db/rebuild_lemmas.py` includes `erdos-register.toml` via `entries/` glob — Erdős rows are metadata until specimens exist.

## WP0-B scope vs later waves

| Wave | Deliverable |
|------|-------------|
| **WP0-B (this)** | Register + schema + sync script + first 20 `E-*` catalog rows + agent doc |
| **WP1+** | `li_specimen` per `target` row, Lean stubs under `proof-db/erdos/`, gap **G-erdos** in `provability-gaps.md` |

Do not mark `proof_status = proved` on catalog rows without a matching Lean discharge and specimen.
