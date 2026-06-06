# Proof Explorer Phase 13 — ten-of-ten closure

**Branch (lic):** `cursor/proof-explorer-phase13-ten-of-ten`  
**Goal sprint:** `data/goal-directed-sprints/proof-explorer-phase13-ten-of-ten.md`  
**Completion gate:** `scripts/proof-explorer-phase13-completion-gate.sh`

## Target state (10/10)

| Dimension | Target |
|-----------|--------|
| Site | `library.json` `lic_commit` == `lic` `origin/main`; 0 divergent, 0 unknown, 0 proc/witness junk |
| Explorer | Phases 1–13 gates pass; loop state complete; no stale PRs blocking |
| Compiler gaps | All `*_gap.sh` run; BUG-C-01 + axiom PASS; remaining OPEN documented in compiler-audit |
| Axiom layer | M-AX `def`+`implies`; phase10 ax gates green |
| Erdős | Honest open/proved labels (no fake proved) |
| K8s | Pod Running, proof-library cloned, `SCALE_DOWN=0`, active phase13 goal |

## Work packages

| WP | Deliverable | Gate |
|----|-------------|------|
| WP-T10-01 | Site sync — `lic_commit` matches lic main | `wp-t10-01-site-sync.sh` |
| WP-T10-02 | Close stale conflicting PRs (#819, #4, old phase PRs) | `wp-t10-02-stale-prs-closed.sh` |
| WP-T10-03 | Rebuild + merge proof-library on main | `wp-t10-03-proof-library-main.sh` |
| WP-T10-04 | Run all `*_gap.sh`; audit index honest | `wp-t10-04-compiler-gaps.sh` |
| WP-T10-05 | stub-audit clean on catalog specimens | `wp-t10-05-stub-audit-catalog.sh` |
| WP-T10-06 | Discrepancy register triage (≤ budget) | `wp-t10-06-discrepancy-triage.sh` |
| WP-T10-07 | Axiom layer M-AX def+implies | `wp-t10-07-axiom-layer.sh` |
| WP-T10-08 | Erdős honest open/proved labels | `wp-t10-08-erdos-honesty.sh` |
| WP-T10-09 | Main CI green (`check-li-def-syntax`, etc.) | `wp-t10-09-main-ci.sh` |
| WP-T10-10 | Phase13 signoff + iteration log | `wp-t10-10-phase13-signoff.sh` |

## Verification

```bash
bash scripts/proof-explorer-phase13-completion-gate.sh
```

## Julian-only backlog

Compiler fixes for BUG-C-02, 04, 05, 06, 08, 12 remain human-owned unless a minimal patch closes a gap script without large scope.
