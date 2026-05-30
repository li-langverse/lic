# Plan cross-links (master plan ↔ gaps ↔ phases)

Agents and contributors use this map so **vision**, **PH trackers**, and **honest proof status** stay aligned across org repos.

## Canonical documents

| Layer | Repository | Path |
|-------|------------|------|
| **Master plan** (PH order, repo policy) | `lic` | [`2026-05-14-li-master-plan.md`](../superpowers/plans/2026-05-14-li-master-plan.md) |
| **Provability gaps (G-*)** | `lic` | [`provability-gaps.md`](../verification/provability-gaps.md) |
| **Phase plans** | `lic` | [`docs/superpowers/plans/`](../superpowers/plans/) (`2026-05-14-phase-*.md`, lip/httpd/math plans) |
| **Proof corpus backlog** | `lic` | [`proof-corpus-roadmap.md`](../verification/proof-corpus-roadmap.md) |
| **Ecosystem governance** | `roadmap` | [vision-and-roadmap](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| **Engineering standards** | `roadmap` | [engineering-standards](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/engineering-standards.md) |
| **Benchmark catalog & dashboard** | `benchmarks` | [catalog.toml](https://github.com/li-langverse/benchmarks/blob/main/catalog.toml) · [handbook](https://github.com/li-langverse/benchmarks/tree/main/docs/handbook) |

**Live handbook URLs:** [Live handbook sites](live-handbook-sites.md).

## Edit rules

1. **Cross-repo or pillar change** → update **master plan** + open **roadmap** proposal (human merge on governance paths).
2. **Close a G-* row** → same PR as the implementation; update **provability-gaps.md** (**Partial** → **Done** only with evidence in the table).
3. **Close a PH phase checkbox** → same PR as the deliverable; link `li-tests` or bench rows where applicable.
4. **Perf claim** → `catalog.toml` row + ingest; cite [benchmarks dashboard](https://li-langverse.github.io/benchmarks/); do not mark proof **Done** from bench green alone.

## Phase plan index (lic)

| Plan | PH / topic |
|------|------------|
| `2026-05-14-phase-00-bootstrap.md` | Bootstrap |
| `2026-05-14-phase-01-lexer-parser.md` | Parser |
| `2026-05-14-phase-02-typechecker.md` | Types |
| `2026-05-14-phase-03-mir-codegen.md` | MIR / LLVM |
| `2026-05-14-phase-04-runtime-stdlib.md` | Runtime / std |
| `2026-05-14-phase-05-tetris.md` | Demo game |
| `2026-05-14-phase-06-self-host.md` | Self-host |
| `2026-05-14-phase-07-native-hpc.md` | **PH-5b**, SIMD / tier-1 |
| `2026-05-14-benchmarks-and-simulations.md` | Bench harness |
| `2026-05-16-li-package-manager-lip.md` | **lip** / **lit** |
| `2026-05-16-li-httpd-plan.md` | **lis** / httpd |
| `2026-05-16-li-math-linalg-surface.md` | Math / **PH-7e** |
| `2026-05-16-li-ecosystem-governance.md` | Org repos, agent-kit |
| `2026-05-22-parallel-compile-ci.md` | **PH-8p** |

## Automation

`python3 scripts/plan-completion-audit.py` (in **benchmarks** repo; `LIC_ROOT` → sibling `lic`) writes `plan-completion-audit.json` (`master_plan_open`, `provability_partial`, `catalog_gaps`). Preflight: [agent-briefing](https://github.com/li-langverse/benchmarks/blob/main/scripts/agent-briefing.py).
