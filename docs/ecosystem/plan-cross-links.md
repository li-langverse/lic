# Plan cross-links (master plan ↔ gaps ↔ phases)

Agents and contributors use this map so **vision**, **PH trackers**, and **honest proof status** stay aligned across repos.

## Canonical documents

| Layer | Path |
|-------|------|
| **Master plan** (PH order, repo policy) | [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md) |
| **Provability gaps (G-*)** | [provability-gaps.md](../verification/provability-gaps.md) |
| **Phase plans** | [docs/superpowers/plans/](../superpowers/plans/) (`2026-05-14-phase-*.md`, lip/httpd/math plans) |
| **Proof corpus roadmap** | [proof-corpus-roadmap.md](../verification/proof-corpus-roadmap.md) |
| **Ecosystem governance** | [roadmap vision](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| **Benchmark catalog & dashboard** | [catalog.toml](https://github.com/li-langverse/benchmarks/blob/main/catalog.toml) · [dashboard](https://li-langverse.github.io/benchmarks/) |
| **Live documentation map** | [live-documentation.md](live-documentation.md) · org Pages URLs |

## Edit rules

1. **Cross-repo or pillar change** → update **master plan** + open **roadmap** proposal (human merge on governance paths).
2. **Close a G-* row** → same PR as the implementation; update **provability-gaps.md** (**Partial** or **Done** only with cited evidence).
3. **Close a PH phase checkbox** → same PR as the deliverable; link `li-tests/` or bench rows where applicable.
4. **Perf claim** → cite dashboard URL; do not mark proof **Done** from bench green alone.

## Phase plan index

| Plan | PH / topic | Gap IDs |
|------|------------|---------|
| [phase-00-bootstrap](../superpowers/plans/2026-05-14-phase-00-bootstrap.md) | Bootstrap | — |
| [phase-02-typechecker](../superpowers/plans/2026-05-14-phase-02-typechecker.md) | Types | — |
| [phase-03-mir-codegen](../superpowers/plans/2026-05-14-phase-03-mir-codegen.md) | MIR / LLVM | **G-bnd** |
| [phase-07-native-hpc](../superpowers/plans/2026-05-14-phase-07-native-hpc.md) | **PH-5b**, SIMD / tier-1 | **G-par**, **G-dec**, **G-math** |
| [benchmarks-and-simulations](../superpowers/plans/2026-05-14-benchmarks-and-simulations.md) | Bench harness | **G-math** |
| [package-manager-lip](../superpowers/plans/2026-05-16-li-package-manager-lip.md) | **lip** / **lit** | — |
| [math-linalg-surface](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) | **PH-2i**, **PH-7e** | **G-math**, **G-lean** |
| [execution-decorators](../superpowers/plans/2026-05-16-li-execution-decorators.md) | **PH-7d** | **G-dec**, **G-par** |

Master plan § [Documentation & provability honesty](../superpowers/plans/2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting) binds **Doc-a … Doc-e** to this register.

## Satellite handbook Pages

Package repos ship minimal GitHub Pages handbooks (`docs/handbook.md`, `site/index.html`, `pages.yml`) — see [live documentation map](live-documentation.md). Until Pages deploy on `main`, use in-repo `docs/handbook.md` in each repo.
