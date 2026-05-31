# Proof Explorer content style guide (schema v3)

**Audience:** agents ingesting Erdős and open-conjecture rows for the Li Proof Library explorer.

**Attribution:** `proof-db/attribution.toml` — footer on every page:

> **Li Proof Library** · Curated by Julian Kleber ([julianmkleber.com](https://julianmkleber.com) / [@capjmk](https://x.com/capjmk))

## Content tiers (`content_tier`)

| Tier | Meaning | Agent rule |
|------|---------|------------|
| `raw` | Auto-ingested from erdosproblems.com or JSON sync | Default for bulk ingest; may omit `latex` |
| `curated` | Human-reviewed statement, tags, and sources | Minimum bar for Tier-A register rows |
| `formalized` | Quantified `.li` specimen linked (`li_specimen`); partial or open discharge | Phase 6+ P0/M-CONJ upgrades; honest partial proofs allowed |
| `polished` | Hand-edited math, context, and citations | **Never overwrite** with auto ingest |

## Required fields (Erdős `E-*` / `kind = target`)

| Field | Rule |
|-------|------|
| `statement` | Plain-text math; ASCII-friendly unless LaTeX duplicate exists |
| `proof_status` | `open`, `proved`, `target`, or `discrepancy` — never `proved` without Lean discharge + literature match |
| `erdos_status` | Mirror published status (`open` / `proved` / `target`) |
| `external_url` | Canonical erdosproblems.com link when numbered |

## Optional rich fields (v3)

| Field | Rule |
|-------|------|
| `latex` | KaTeX-safe subset; escape `%`, `_` outside math mode |
| `context` | 1–3 sentences: history, prize, or related results |
| `sources` | Array of `{ title, url }` or comma-separated citation keys |
| `notes` | Curator-only; not shown as main body |

## Proof honesty

- Do **not** set `proof_status = proved` without Lean discharge **and** a literature match.
- Do **not** downgrade `content_tier = polished` rows during sync scripts.
- Prefer `register.json` → `erdos-register.toml` pipeline over hand-editing 75+ TOML rows.

## Footer rendering

UI and static export must include both lines from `[footer]` in `proof-db/attribution.toml`.
