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
| `2026-05-30-ph7e-tier1-red-benchmark-honesty.md` | **PH-7e** tier-1 honesty · **G-math** doc sync |
| `2026-05-16-li-execution-decorators.md` (spec) | **PH-7d** · **G-dec**, **G-par** |
| `2026-05-16-li-llm-first-design.md` (spec) | **Vision-LLM** — agent JSON diagnostics (no **G-*** closure) |

## Open master-plan tracker rows (2026-05-30)

Preflight: `benchmarks/data/latest/ecosystem-audit.json` · `plan_completion_audit.summary.open_tracker_items: 5`. Do not mark **Done** without cited evidence.

| PH | Gap ID(s) | Phase plan (lic) |
|----|-----------|------------------|
| **2i** — Math / linalg | **G-math**, **G-math-syn** | [2026-05-16-li-math-linalg-surface.md](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) |
| **7d** — Execution decorators | **G-dec**, **G-par** | [2026-05-16-li-execution-decorators.md](../superpowers/specs/2026-05-16-li-execution-decorators.md) · [phase-07-native-hpc](../superpowers/plans/2026-05-14-phase-07-native-hpc.md) |
| **7e** — Math → SIMD lowering | **G-math** | [2026-05-16-li-math-linalg-surface.md](../superpowers/plans/2026-05-16-li-math-linalg-surface.md) · [ph7e-tier1-red-benchmark-honesty](../superpowers/plans/2026-05-30-ph7e-tier1-red-benchmark-honesty.md) |
| **8p** — Parallel compile / CI | — | [2026-05-22-parallel-compile-ci.md](../superpowers/plans/2026-05-22-parallel-compile-ci.md) |
| **Vision-LLM** — Agent JSON diagnostics | — | [2026-05-16-li-llm-first-design.md](../superpowers/specs/2026-05-16-li-llm-first-design.md) |

## UI/UX quality (`ui_ux_quality` research goal)

Surface quality is **not** proof — keep separate from **G-*** rows. Supports **`gui_ux_tester`**, **`docs_ui_tester`**, **`studio_ui_ux_builder`**.

| Agent | Surface | Latest digest / audit |
|-------|---------|------------------------|
| `gui_ux_tester` | GUI apps, fixtures, native SDL | [2026-05-30-gui-ui.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/ux-digests/2026-05-30-gui-ui.md) · `data/latest-gui-ui-run/ui-audit.json` |
| `docs_ui_tester` | MkDocs / handbook Pages | [2026-05-30-docs-ui.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/ux-digests/2026-05-30-docs-ui.md) · [2026-05-30-docs-ux.md](https://github.com/li-langverse/benchmarks/blob/main/docs/ecosystem/ux-digests/2026-05-30-docs-ux.md) |
| `studio_ui_ux_builder` | PH-UX plan loop, bench gates | [studio-ui-ux-builder-digest](https://github.com/li-langverse/benchmarks/blob/main/data/latest/studio-ui-ux-builder-digest.md) |

| Layer | Path |
|-------|------|
| **Handoff (this repo)** | [gui-ux-quality-handoff.md](gui-ux-quality-handoff.md) |
| **Orchestrator ingest** | [orch-r4-ui-ux-signals](orchestrator-notes/2026-05-29-orch-r4-ui-ux-signals.md) |
| **Remediation manifest** | `benchmarks/data/latest/remediation_manifest.json` |
| **Targets** | `li-cursor-agents/config/ux-targets.json` |

**Preflight note:** briefing `data/latest/ux-audit.json` is often **docs-only** (`lic-docs`). GUI rows require proactive `data/latest-gui-ui-run/ui-audit.json` with **all** GUI targets exercised — not a single-target native rerun.

### Live handbook vs audit HEAD (2026-05-30)

`ecosystem-audit.json` reports `repos_without_live_docs: []` and `live_docs_down: []` (URL roots respond). **Content** on [li-language Pages](https://li-langverse.github.io/li-language/) can still be **stale** (5-tab nav vs 12-tab local `mkdocs.yml`; hero paths 404) until [lic#403](https://github.com/li-langverse/lic/issues/403) strict build + deploy lands. Treat audit green as **reachability**, not **IA freshness** — see docs-ux digest above.

## Automation

`python3 scripts/plan-completion-audit.py` in **benchmarks** ( **LIC_ROOT** = sibling `lic` ) writes `data/latest/plan-completion-audit.json` — `master_plan_open` = tracker rows only.
