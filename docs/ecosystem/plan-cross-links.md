# Plan cross-links (master plan ↔ gaps ↔ phases)

Agents use this map so **vision**, **PH trackers**, and **honest proof status** stay aligned across repos. Mirror in [benchmarks](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/plan-cross-links.md) for explorer digests.

## Canonical documents

| Layer | Repository | Path |
|-------|------------|------|
| **Master plan** (PH order, repo policy) | `lic` | [2026-05-14-li-master-plan.md](../superpowers/plans/2026-05-14-li-master-plan.md) |
| **Provability gaps (G-*)** | `lic` | [provability-gaps.md](../verification/provability-gaps.md) |
| **Phase plans** | `lic` | [docs/superpowers/plans/](../superpowers/plans/) (`2026-05-14-phase-*.md`, lip/httpd/math plans) |
| **Handbook index** | `lic` | [docs/handbook/README.md](../handbook/README.md) |
| **Ecosystem governance** | `roadmap` | [vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) |
| **Milestones (themes)** | `roadmap` | [milestones.md](https://github.com/li-langverse/roadmap/blob/main/docs/roadmap/milestones.md) |
| **Benchmark catalog & dashboard** | `benchmarks` | [catalog.toml](https://github.com/li-langverse/benchmarks/blob/main/catalog.toml) · [dashboard](https://li-langverse.github.io/benchmarks/) |

## Edit rules

1. **Cross-repo or pillar change** → update **master plan** + open **roadmap** proposal (human merge on governance paths).
2. **Close a G-* row** → same PR as the implementation; update **provability-gaps.md** (Partial → Done only with evidence cited in the table).
3. **Close a PH phase checkbox** → same PR as the deliverable; link bench rows or `li-tests` where applicable.
4. **Perf claim** → `catalog.toml` row + ingest; cite dashboard URL; do not mark proof **Done** from bench green alone.

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
| `2026-05-16-li-package-manager-lip.md` | **lip** |
| `2026-05-16-li-httpd-plan.md` | **lis** / httpd |
| `2026-05-16-li-math-linalg-surface.md` | Math / **PH-7e** · **G-math**, **G-math-syn** |
| `2026-05-22-parallel-compile-ci.md` | **PH-8p** (CI throughput; no **G-*** closure) |
| `2026-05-24-studio-ui-ux-plan-loop.md` | **PH-UX** / Studio (UX honesty, not Lean) |
| `2026-05-20-li-oop-roadmap.md` | **PH-2j** · **G-oop**, **G-def** |
| `2026-05-16-li-package-scaffold.md` | **Pkg** / **8a** |
| `2026-05-16-li-ecosystem-governance.md` | **PH-Pkg** governance |
| `ph-db-lidb-platform.md` | **PH-DB** (roadmap ADR owns detail) |

## UI/UX quality (`ui_ux_quality` research goal)

| Layer | Path |
|-------|------|
| **Handoff (this repo)** | [gui-ux-quality-handoff.md](gui-ux-quality-handoff.md) |
| **Orchestrator ingest** | [orch-r4-ui-ux-signals](orchestrator-notes/2026-05-29-orch-r4-ui-ux-signals.md) |
| **UX digests** | `benchmarks/docs/ecosystem/ux-digests/` (`*-gui-ux.md`, `*-gui-ui.md`) |
| **Targets** | `li-cursor-agents/config/ux-targets.json` |

Primary agent: **`gui_ux_tester`**. Companion: **`gui_ui_tester`** (axe/pixel). Implementation: **`studio_ui_ux_builder`**.

## Automation

`python3 scripts/plan-completion-audit.py` in **benchmarks** ( **LIC_ROOT** = sibling `lic` ) writes `data/latest/plan-completion-audit.json` — `master_plan_open` = tracker rows only.
