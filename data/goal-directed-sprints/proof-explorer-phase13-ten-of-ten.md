---
workflow_repo: lic
branch: cursor/proof-explorer-phase13-ten-of-ten
plan: docs/superpowers/plans/proof-explorer-phase13-ten-of-ten.md
proof_library_branch: main
---

# Proof Explorer Phase 13 — ten-of-ten

## North star

Close every Proof Explorer dimension to **10/10**: site synced to lic main, explorer loop through phase 13, honest compiler-gap audit, axiom layer green, Erdős labels honest, K8s worker on this goal until gate passes.

## Workspace layout (K8s / local)

- **lic** checkout: `/workspace/lic` — catalog, Lean, gates (`LIC_ROOT`).
- **proof-library**: sibling `../proof-library` — ingest, PR, Pages.

```bash
export LIC_ROOT=/workspace/lic
python3 scripts/proof-db/compare_reference.py --write
cd /workspace/proof-library
LIC_ROOT=/workspace/lic python3 scripts/build-library.py
bash scripts/check-library-quality.sh
python3 scripts/check-no-proc-in-library.py
```

## Iteration rules

1. Branch **`cursor/proof-explorer-phase13-ten-of-ten`** in **lic**.
2. Close stale PRs (#819 lic, #4 proof-library, superseded phase PRs) via `gh close` with comment.
3. Rebuild proof-library from lic main; open PR; merge when CI green.
4. Run `li-tests/tooling/*_gap.sh`; update `docs/reports/compiler-audit/README.md` for OPEN gaps.
5. Minimal compiler fixes only when gap script is small-scope (dot4 done; axiom partial).
6. Run `bash scripts/proof-explorer-gates/wp-t10-*.sh` then `bash scripts/proof-explorer-phase13-completion-gate.sh`.

## Phase checklist

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-T10-01 | library.json lic_commit == origin/main | `wp-t10-01-site-sync.sh` |
| WP-T10-02 | stale PRs closed | `wp-t10-02-stale-prs-closed.sh` |
| WP-T10-03 | proof-library merged on main | `wp-t10-03-proof-library-main.sh` |
| WP-T10-04 | gap scripts + compiler-audit | `wp-t10-04-compiler-gaps.sh` |
| WP-T10-05 | stub-audit catalog clean | `wp-t10-05-stub-audit-catalog.sh` |
| WP-T10-06 | discrepancy register ≤ budget | `wp-t10-06-discrepancy-triage.sh` |
| WP-T10-07 | M-AX axiom layer | `wp-t10-07-axiom-layer.sh` |
| WP-T10-08 | Erdős honest labels | `wp-t10-08-erdos-honesty.sh` |
| WP-T10-09 | main CI green | `wp-t10-09-main-ci.sh` |
| WP-T10-10 | signoff + iteration log | `wp-t10-10-phase13-signoff.sh` |

## Do not

- Mark Erdős **proved** when register is **open** / **target**.
- Ship `proc` or `_axiom_witness` / `def main()` in library **li_specimen** snippets.
- Large compiler refactors from this goal.

## Completion gate

```bash
bash scripts/proof-explorer-phase13-completion-gate.sh
```
