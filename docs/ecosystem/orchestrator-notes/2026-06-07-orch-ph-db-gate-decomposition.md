# Orchestrator mapping — PH-DB gate decomposition (lic#423)

**Date:** 2026-06-07  
**Plan:** [2026-06-07-ph-db-gate-decomposition.md](../superpowers/plans/2026-06-07-ph-db-gate-decomposition.md)  
**Issue:** [lic#423](https://github.com/li-langverse/lic/issues/423)

## Agent routing

| Phase issue | Primary agent | Gate IDs | Backlog target |
|-------------|---------------|----------|----------------|
| PH-DB-2 engine | `code_implementer` | A01–A06, TRK-A* | `lidb` |
| PH-DB-3 lis db | `code_implementer` | B01–B06, TRK-B*, TRK-I* | `lis` |
| PH-DB-5 bench | `benchmark_maintainer` | C01–C06, TRK-C*, TRK-K* | `benchmarks` |
| PH-DB-4 registry | `code_implementer` + human | D01–D06, TRK-D* | `lidb`, `lip` |
| PH-DB-10 control plane | `code_implementer` | E01–E07, TRK-E*, TRK-G* | `li-cursor-agents` |
| PH-DB-G0 research | `researcher` | F01–F05, TRK-F01 | `research-findings` |
| PH-DB-W3 CI | `ci_maintainer` | TRK-G…K, TRK-P01–P04 | multi |

## Swarm runner

After [lic#765](https://github.com/li-langverse/lic/pull/765) merges: `python3 scripts/ph-db-plan-loop.py` picks todos; gate IDs from decomposition plan close in owner-repo PRs with CI cite.

## North star

**G-proof-db** (Partial) · **PH-DB-1…10** · proof before perf
