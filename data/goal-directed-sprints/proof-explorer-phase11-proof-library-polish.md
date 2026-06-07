---
workflow_repo: lic
branch: cursor/proof-library-site-polish
plan: docs/superpowers/plans/proof-explorer-phase11-proof-library-polish.md
proof_library_branch: cursor/proof-library-site-polish
---

# Proof Explorer Phase 11 — proof-library site polish

## North star

Refresh **proof-library** `data/library.json` from **lic `main`** (or current `LIC_ROOT`), cut **lean_status unknown**, wire **stdlib drilldowns**, strip **witness/main Li boilerplate**, enrich **Erdős** formal previews, and deploy **GitHub Pages**.

## Workspace layout (K8s / local)

- **lic** checkout: `/workspace/lic` — catalog + Lean sources (`LIC_ROOT` for rebuild).
- **proof-library**: sibling `../proof-library` or monorepo `proof-library/` — run ingest + commit + PR from there.

```bash
export LIC_ROOT=/workspace/lic
cd /workspace/proof-library   # or ../proof-library from lic
python3 scripts/build-library.py
bash scripts/check-library-quality.sh
python3 scripts/check-no-proc-in-library.py
```

## Iteration rules

1. Branch **`cursor/proof-library-site-polish`** in **proof-library** (site + `library.json`).
2. Optional lic branch with same name for sprint docs + gates only (no proof-db edits required unless scan gaps found).
3. Push proof-library; open PR; merge when CI green; confirm Pages deploy.
4. Run lic gates: `bash scripts/proof-explorer-gates/wp-pl-*.sh` then `bash scripts/proof-explorer-phase11-completion-gate.sh`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-PL-01 | Rebuild `library.json` from current lic | `wp-pl-01-rebuild-json.sh` |
| WP-PL-02 | Expanded Lean scan + lean_status | `wp-pl-02-lean-scan.sh` |
| WP-PL-03 | Snippet strip (no witness/main) | `wp-pl-03-snippet-strip.sh` |
| WP-PL-04 | Stdlib drilldowns (5 rows) | `wp-pl-04-stdlib-drilldown.sh` |
| WP-PL-05 | Erdős formal_statement drilldown | `wp-pl-05-erdos-formal.sh` |
| WP-PL-06 | Pages deploy / merge proof-library | `wp-pl-06-pages-deploy.sh` |

## Do not

- Mark Erdős **proved** in UI when catalog is **open** / **target**.
- Ship `proc` or `_axiom_witness` / `def main()` in **li_specimen** snippets.
- Edit `compiler/` from this goal.

## Completion gate

```bash
bash scripts/proof-explorer-phase11-completion-gate.sh
```
