# Phase plans index

Cross-links **master plan** phases, detailed phase plan files, and **G-*** provability gaps. Update when adding a new phase plan or closing a gap row.

**Master plan:** [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md)  
**Gap register:** [provability-gaps.md](../verification/provability-gaps.md)  
**Compiler task map:** [Master plan — Compiler tasks vs proof gaps](../superpowers/plans/2026-05-14-li-master-plan.md)

| Phase | Plan file | Primary G-* gaps |
|-------|-----------|------------------|
| 0 — Bootstrap | [phase-00-bootstrap.md](../superpowers/plans/2026-05-14-phase-00-bootstrap.md) | — (toolchain) |
| 1 — Lexer/Parser | [phase-01-lexer-parser.md](../superpowers/plans/2026-05-14-phase-01-lexer-parser.md) | — |
| 2 — Typechecker | [phase-02-typechecker.md](../superpowers/plans/2026-05-14-phase-02-typechecker.md) | [G-vc](../verification/provability-gaps.md#g-vc), [G-bnd](../verification/provability-gaps.md#g-bnd), [G-def](../verification/provability-gaps.md#g-def), [G-math-syn](../verification/provability-gaps.md#g-math-syn) |
| 3 — MIR/Codegen | [phase-03-mir-codegen.md](../superpowers/plans/2026-05-14-phase-03-mir-codegen.md) | [G-bnd](../verification/provability-gaps.md#g-bnd), [G-meta](../verification/provability-gaps.md#g-meta) |
| 4 — Runtime/Stdlib | [phase-04-runtime-stdlib.md](../superpowers/plans/2026-05-14-phase-04-runtime-stdlib.md) | [G-stdlib](../verification/provability-gaps.md#g-stdlib) |
| 5 — Tetris | [phase-05-tetris.md](../superpowers/plans/2026-05-14-phase-05-tetris.md) | — (integration milestone) |
| 6 — Self-host | [phase-06-self-host.md](../superpowers/plans/2026-05-14-phase-06-self-host.md) | [G-lean](../verification/provability-gaps.md#g-lean) (bootstrap path) |
| 7 — Native HPC | [phase-07-native-hpc.md](../superpowers/plans/2026-05-14-phase-07-native-hpc.md) | [G-par](../verification/provability-gaps.md#g-par), [G-dec](../verification/provability-gaps.md#g-dec), [G-math](../verification/provability-gaps.md#g-math) |
| 8p — Parallel CI | [parallel-compile-ci.md](../superpowers/plans/2026-05-22-parallel-compile-ci.md) | — (throughput; see master plan § 8p) |
| 2i — Math surface | [li-math-linalg-surface.md](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) | [G-math](../verification/provability-gaps.md#g-math) |
| 8 — lip/lit | [li-package-manager-lip.md](../superpowers/plans/2026-05-16-li-package-manager-lip.md) | supply-chain (not G-*) |
| H — HTTPd | [li-httpd-plan.md](../superpowers/plans/2026-05-16-li-httpd-plan.md) | [G-net](../verification/provability-gaps.md#g-net) |
| Doc — Honesty | [Master plan § Doc](../superpowers/plans/2026-05-14-li-master-plan.md) | all open [G-*](../verification/provability-gaps.md#still-open-report-every-session) |

## Org repo handbooks

Repos flagged without standalone GitHub Pages publish handbook stubs here (deployed via **lic** → **li-language** site):

| Repo | Handbook |
|------|----------|
| lic | [lic.md](lic.md) |
| lip | [lip.md](lip.md) |
| lit | [lit.md](lit.md) |
| lis | [lis.md](lis.md) |
| li-httpd | [li-httpd.md](li-httpd.md) |
| li-net | [li-net.md](li-net.md) |
| li-std-core | [li-std-core.md](li-std-core.md) |
| li-std-math | [li-std-math.md](li-std-math.md) |
| li-demo | [li-demo.md](li-demo.md) |
| roadmap | [roadmap.md](roadmap.md) |
