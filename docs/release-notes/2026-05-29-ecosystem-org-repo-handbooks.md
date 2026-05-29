# Ecosystem org-repo handbooks + phase cross-links

## Summary

Adds published handbook stubs for all ten `repos_without_live_docs` audit repos (served via **lic** → **li-language** GitHub Pages), a phase-plans index linking master plan ↔ **G-***, and fixes a duplicate appendix in `provability-gaps.md`.

## Changed

| Path | Note |
|------|------|
| `docs/ecosystem/{lip,lit,lic,lis,li-httpd,li-net,li-std-core,li-std-math,li-demo,roadmap}.md` | Org repo handbook stubs |
| `docs/ecosystem/phase-plans-index.md` | Master plan ↔ phase plans ↔ G-* map |
| `docs/ecosystem/official-packages.md` | Handbook column |
| `docs/verification/provability-gaps.md` | Phase index link; dedupe appendix; date |
| `docs/superpowers/plans/2026-05-14-phase-*.md` | Master plan + gap cross-links (00–07) |
| `mkdocs.yml`, `docs/index.md`, `README.md` | Nav + discovery |

## Not changed

- Compiler, CI workflows, per-repo README mirrors (follow-up PRs in lip/lit/…).

## Breaking

N/A.

## Security / Performance / Downstream

Docs-only. Bench claims remain **Partial** with evidence requirements unchanged.
