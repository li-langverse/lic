# Proof database extension roadmap

**Status:** WP0-A (schema v2 + vertical stubs) — 2026-05-30  
**Audience:** agents extending the multi-domain proof catalog  
**Related:** [proof-database](proof-database.md) · [schema.toml](proof-database/schema.toml) · [proof-corpus-roadmap.md](proof-corpus-roadmap.md)

## Goal

Grow the Li proof database from math/physics/linalg into numerics, discrete math, statistics, ML convergence, graph theory, Erdős problems, and computational chemistry/biology — without overclaiming proof status.

## WP0 — Infrastructure (current)

| Slice | ID prefixes | Entry files | Gap |
|-------|-------------|-------------|-----|
| Numerics | `N-AX-*`, `N-LM-*` | `numerics-*.toml` | **G-num** |
| Discrete | `D-AX-*`, `D-LM-*` | `discrete-*.toml` | **G-discrete** |
| Statistics | `ST-AX-*`, `ST-LM-*` | `statistics-*.toml` | **G-stats** |
| ML | `ML-AX-*`, `ML-LM-*` | `ml-*.toml` | **G-ml** |
| Graph | `GT-AX-*`, `GT-LM-*` | `graph-*.toml` | **G-graph** |
| Erdős | `E-*` | `erdos-register.toml` | **G-erdos** |
| Chemistry | `CHEM-*` | `chemistry-*.toml` | **G-chem** |
| Biology | `BIO-*` | `biology-*.toml` | **G-bio** |

### Schema v2

Optional catalog fields: `domain`, `erdos_id`, `erdos_status`, `convergence_class`, `benchmark_ref`, `mathlib_ref`, `priority_tier`.

New `proof_status`: **`target`** — aspirational row; not discharged. Use **`open`** for in-scope work with specimens; never mark stubs `proved`.

### Agent workflow

1. Add row to the vertical `entries/*.toml` file (required fields + honest `proof_status`).
2. Run `python3 scripts/proof-db/proof-db.py verify-slice`.
3. Wire Lean / `.li` specimen when moving from `target` → `open` → `proved`.
4. Regenerate [proof-library](https://github.com/li-langverse/proof-library) via `scripts/build-library.py`.

## Later phases (summary)

| WP | Focus | Depends on |
|----|-------|------------|
| WP0-B | Erdős register JSON + sync | WP0-A |
| WP1 | Numerics + discrete proofs | G-num, G-discrete |
| WP2 | Statistics layer | G-stats |
| WP3 | ML convergence (Lean + specimens) | G-ml |
| WP4 | Graph theory foundations | G-graph |
| WP5 | Erdős tranches (P0–P3) | WP4, register |
| WP6–8 | Physics extend, chem, bio | G-physics, G-chem, G-bio |

## Exit criteria (WP0-A)

- [x] `schema.toml` v2 with optional fields + `target` status
- [x] Stub entry TOML per vertical (14 files)
- [x] `proof-db/manifest.toml` catalog slice registry
- [x] `proof-library` build + UI badge for `target`
- [ ] WP0-B: full Erdős register ingest
- [ ] G-* gap rows in `provability-gaps.md` (follow-up doc PR)
